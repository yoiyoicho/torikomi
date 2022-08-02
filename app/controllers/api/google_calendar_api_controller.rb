class Api::GoogleCalendarApiController < ApplicationController
  # 下記のドキュメントをもとに実装
  # https://developers.google.com/identity/protocols/oauth2/web-server#ruby_1
  # https://googleapis.dev/ruby/google-api-client/v0.20.1/Google/APIClient/ClientSecrets.html
  # https://googleapis.dev/ruby/google-api-client/latest/Google/Apis/CalendarV3/CalendarService.html
  # https://www.rubydoc.info/github/google/signet/Signet/OAuth2/Client

  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets'
  require 'sidekiq/api'

  before_action :set_auth_client

  def authorize
    auth_uri = @auth_client.authorization_uri
    redirect_to auth_uri, allow_other_host: true
  end

  def callback
    if params[:code].present?
      @auth_client.code = params[:code]
      @auth_client.fetch_access_token!

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = @auth_client

      google_calendar_token = GoogleCalendarToken.find_or_initialize_by(user: current_user)
      google_calendar_token.assign_attributes(access_token: @auth_client.access_token, refresh_token: @auth_client.refresh_token, expires_at: @auth_client.expires_at, google_calendar_id: service.get_calendar('primary').id)

      if google_calendar_token.save
        redirect_back_or_to dashboards_path, success: 'Googleカレンダーと連携しました'
      else
        redirect_back_or_to dashboards_path, error: 'Googleカレンダーと連携できませんでした'
      end
    else
      redirect_back_or_to dashboards_path, error: 'Googleカレンダーと連携できませんでした'
    end
  end

  def update
    if current_user.google_calendar_token.present?
      set_schedules_from_google_calendar(current_user.google_calendar_token)
      redirect_to dashboards_path, success: 'Googleカレンダーからスケジュールを取得しました'
    else
      redirect_to dashboards_path, error: 'Googleカレンダーからスケジュールを更新できませんでした'
    end
  end

  def set_schedules_from_google_calendar(google_calendar_token)

    user = google_calendar_token.user

    # access_tokenが期限切れの場合は、refresh_tokenを使って新しいaccess_tokenを取得する
    @auth_client.refresh_token =  google_calendar_token[:refresh_token]
    if google_calendar_token.expires_at < Time.zone.now
      @auth_client.refresh!
      google_calendar_token.update!(access_token: @auth_client.access_token, expires_at: @auth_client.expires_at)
    else
      @auth_client.access_token = google_calendar_token[:access_token]
    end

    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = @auth_client

    # 現在から1か月先までのeventを取得
    events = @service.list_events('primary', time_min: Time.zone.now.rfc3339, time_max: 1.month.since.in_time_zone.rfc3339 )
    events.items.each do |item|
      
      start_time = item.start.date_time&.in_time_zone || item.start.date&.in_time_zone
      end_time = item.end.date_time&.in_time_zone || item.end.date&.tomorrow.in_time_zone

      # google_calendar_settingの条件と曜日・時間帯が合致するかどうか
      if valid_event?(user.google_calendar_setting, start_time)
        i_cal_uid = item.i_cal_uid
        schedule = user.schedules.find_or_initialize_by(i_cal_uid: i_cal_uid)

        title = item.summary
        body = item.description #最大160字（後ろから数えて）

        schedule.assign_attributes(start_time: start_time, end_time: end_time, title: title, body: body, resource_type: :google)
        schedule.save!

        if schedule.changed?
          # Sidekiqに登録されているLINEメッセージの送信ジョブを削除する
          if schedule.job_id.present?
            ss = Sidekiq::ScheduledSet.new
            jobs = ss.select { |job| job.args[0]['job_id'] == schedule.job_id }
            jobs.each(&:delete)
          end

          # 新しくジョブを登録する
          job = SendLineMessageJob.set(wait_until: schedule.start_time - schedule.user.setting.notification_time*60).perform_later(schedule.id)
          schedule.update!(job_id: job.job_id, status: :to_be_sent)
        end
      end
    end
  end

  private

  def set_auth_client
    client_secrets = Google::APIClient::ClientSecrets.new({
      "web":{
        "client_id":ENV['GOOGLE_CALENDAR_CLIENT_ID'],
        "auth_uri":"https://accounts.google.com/o/oauth2/auth",
        "token_uri":"https://oauth2.googleapis.com/token",
        "client_secret":ENV['GOOGLE_CALENDAR_CLIENT_SECRET'],
        "redirect_uris":[api_google_calendar_callback_url]
      }
    })
    @auth_client = client_secrets.to_authorization
    @auth_client.update!(
      scope: 'https://www.googleapis.com/auth/calendar.readonly',
      additional_parameters: {
        access_type: 'offline',
        prompt: 'consent',
        session: false
      }
    )
  end

  def valid_event?(google_calendar_setting, start_time)

    flag = google_calendar_setting.monday if start_time.wday == 1
    flag = google_calendar_setting.tuesday if start_time.wday == 2
    flag = google_calendar_setting.wednesday if start_time.wday == 3
    flag = google_calendar_setting.thursday if start_time.wday == 4
    flag = google_calendar_setting.friday if start_time.wday == 5
    flag = google_calendar_setting.saturday if start_time.wday == 6
    flag = google_calendar_setting.sunday if start_time.wday == 7

    start_time_min = start_time.hour * 60 + start_time.min
    start_time_min_s = google_calendar_setting.start_time_hour * 60 + google_calendar_setting.start_time_min
    end_time_min_s = google_calendar_setting.end_time_hour * 60 + google_calendar_setting.end_time_min

    if flag && start_time_min >= start_time_min_s && start_time_min <= end_time_min_s
      true
    else
      false
    end
  end
end