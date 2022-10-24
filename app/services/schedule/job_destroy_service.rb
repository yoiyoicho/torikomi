class Schedule::JobDestroyService
  require 'sidekiq/api'

  def initialize(schedule)
    @schedule = schedule
  end

  def call
    # Sidekiqに登録されているLINEメッセージの送信ジョブを削除する
    ss = Sidekiq::ScheduledSet.new
    jobs = ss.select { |job| job.args[0]['job_id'] == @schedule.job_id }
    jobs.each(&:delete)
    @schedule.update!(job_id: '')
  end
end