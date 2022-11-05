class GoogleCalendar::ScheduleSetService
  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets'

  def initialize(user, auth_client)
    @user = user
    @auth_client = auth_client
  end

  def call

    # refresh_tokenを使って新しいaccess_tokenを取得する
    @auth_client.refresh_token = @user.google_calendar_token[:refresh_token]
    @auth_client.refresh!

    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = @auth_client

    # 既存のGoogleカレンダーから取得したスケジュールのi_cal_uid
    existing_i_cal_uids = @user.schedules.google.pluck(:i_cal_uid)

    # 現在から1か月先までのeventを取得
    events = @service.list_events('primary', time_min: Time.zone.now.rfc3339, time_max: 1.month.since.in_time_zone.rfc3339 )
    events.items.each do |item|

      # 非公開のイベントは取得しない
      if item.visibility != 'private'

        start_time = (item.start&.date_time || item.start&.date)&.in_time_zone
        end_time = (item.end&.date_time || item.end&.date&.tomorrow)&.in_time_zone

        i_cal_uid = item.i_cal_uid
        schedule = @user.schedules.find_or_initialize_by(i_cal_uid: i_cal_uid, resource_type: :google)

        title = item.summary
        body = item.description #最大160字（後ろから数えて）

        schedule.assign_attributes(start_time: start_time, end_time: end_time, title: title, body: body)

        if schedule.changed? && schedule.save
          destroy_service = Schedule::JobDestroyService.new(schedule)
          destroy_service.call

          set_service = Schedule::JobSetService.new(schedule)
          set_service.call
        end

        existing_i_cal_uids.delete(i_cal_uid)
      end
    end

    # 前回以前の更新で取得していたが、今はGoogleカレンダーから削除されているスケジュールを削除
    existing_i_cal_uids.each do |i_cal_uid|
      schedule = Schedule.find_by(i_cal_uid: i_cal_uid)
      destroy_service = Schedule::JobDestroyService.new(schedule)
      destroy_service.call
      schedule.destroy!
    end
  end
end