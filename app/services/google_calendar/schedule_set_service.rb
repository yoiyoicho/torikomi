class GoogleCalendar::ScheduleSetService
  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets'
  require 'sidekiq/api'

  def initialize(user, auth_client)
    @user = user
    @auth_client = auth_client
  end

  def call

    # access_tokenが期限切れの場合は、refresh_tokenを使って新しいaccess_tokenを取得する
    @auth_client.refresh_token = @user.google_calendar_token[:refresh_token]
    if @user.google_calendar_token.expires_at < Time.zone.now
      @auth_client.refresh!
      @user.google_calendar_token.update!(access_token: @auth_client.access_token, expires_at: @auth_client.expires_at)
    else
      @auth_client.access_token = @user.google_calendar_token[:access_token]
    end

    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = @auth_client

    # 既存のGoogleカレンダーから取得したスケジュールのi_cal_uid
    existing_i_cal_uids = @user.schedules.google.pluck(:i_cal_uid)

    # 現在から1か月先までのeventを取得
    events = @service.list_events('primary', time_min: Time.zone.now.rfc3339, time_max: 1.month.since.in_time_zone.rfc3339 )
    events.items.each do |item|

      # 非公開のイベントは取得しない
      if item.visibility != 'private'

        start_time = item.start.date_time&.in_time_zone || item.start.date&.in_time_zone
        end_time = item.end.date_time&.in_time_zone || item.end.date&.tomorrow.in_time_zone

        i_cal_uid = item.i_cal_uid
        schedule = @user.schedules.find_or_initialize_by(i_cal_uid: i_cal_uid, resource_type: :google)

        title = item.summary
        body = item.description #最大160字（後ろから数えて）

        schedule.assign_attributes(start_time: start_time, end_time: end_time, title: title, body: body)

        if schedule.changed? && schedule.save
          # Sidekiqに登録されているLINEメッセージの送信ジョブを削除する
          if schedule.job_id.present?
            ss = Sidekiq::ScheduledSet.new
            jobs = ss.select { |job| job.args[0]['job_id'] == schedule.job_id }
            jobs.each(&:delete)
          end
          # 新しくジョブを登録する
          if schedule.to_be_sent?
            job = SendLineMessageJob.set(wait_until: schedule.start_time - schedule.user.setting.notification_time*60).perform_later(schedule.id)
            schedule.update!(job_id: job.job_id)
          end
        end

        existing_i_cal_uids.delete(i_cal_uid)
      end
    end

    # 前回以前の更新で取得していたが、今はGoogleカレンダーから削除されているスケジュールを削除
    existing_i_cal_uids.each do |i_cal_uid|
      schedule = Schedule.find_by(i_cal_uid: i_cal_uid)
      if schedule.job_id.present?
        ss = Sidekiq::ScheduledSet.new
        jobs = ss.select { |job| job.args[0]['job_id'] == schedule.job_id }
        jobs.each(&:delete)
      end
      schedule.destroy!
    end
  end

  # private

  # google_calendar_settingの条件と曜日・時間帯が合致するかどうか
  # def valid_event?(google_calendar_setting, start_time)
  #
  #   flag = google_calendar_setting.monday if start_time.wday == 1
  #   flag = google_calendar_setting.tuesday if start_time.wday == 2
  #   flag = google_calendar_setting.wednesday if start_time.wday == 3
  #   flag = google_calendar_setting.thursday if start_time.wday == 4
  #   flag = google_calendar_setting.friday if start_time.wday == 5
  #   flag = google_calendar_setting.saturday if start_time.wday == 6
  #   flag = google_calendar_setting.sunday if start_time.wday == 7
  #
  #   start_time_min = start_time.hour * 60 + start_time.min
  #   start_time_min_s = google_calendar_setting.start_time_hour * 60 + google_calendar_setting.start_time_min
  #   end_time_min_s = google_calendar_setting.end_time_hour * 60 + google_calendar_setting.end_time_min
  # 
  #   if flag && start_time_min >= start_time_min_s && start_time_min <= end_time_min_s
  #     true
  #   else
  #     false
  #   end
  # end
end