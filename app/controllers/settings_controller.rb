class SettingsController < ApplicationController
  require 'sidekiq/api'
  before_action :set_setting

  def show
  end

  def edit
    session[:previous_url] = request.referer
  end

  def update
    notification_time_before = @setting.notification_time
    if @setting.update(setting_params)
      if notification_time_before != @setting.notification_time
        current_user.schedules.to_be_sent.each do |schedule|
          # Sidekiqに登録されているLINEメッセージの送信ジョブを削除する
          ss = Sidekiq::ScheduledSet.new
          jobs = ss.select { |job| job.args[0]['job_id'] == schedule.job_id }
          jobs.each(&:delete)

          # 新しくジョブを登録する
          job = SendLineMessageJob.set(wait_until: schedule.start_time - @setting.notification_time*60).perform_later(schedule.id)
          schedule.update!(job_id: job.job_id)
        end
      end
      redirect_to session[:previous_url] ||= dashboards_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :edit
    end
  end

  private

  def set_setting
    @setting = current_user.setting
  end

  def setting_params
    params.require(:setting).permit(:notification_time, :message_option, :message_text)
  end
end
