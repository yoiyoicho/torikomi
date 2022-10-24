class Schedule::JobSetService
  def initialize(schedule)
    @schedule = schedule
  end

  def call
    if @schedule.to_be_sent?
      # スケジュール開始時間からユーザーが設定した分数だけ前に、LINEメッセージの送信ジョブを追加
      job = SendLineMessageJob.set(wait_until: @schedule.start_time - @schedule.user.setting.notification_time*60).perform_later(@schedule.id)
      @schedule.update!(job_id: job.job_id)
    end
  end
end