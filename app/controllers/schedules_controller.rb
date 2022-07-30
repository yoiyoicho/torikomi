class SchedulesController < ApplicationController
  require 'sidekiq/api'

  def index
    @schedules = current_user.schedules.order(:start_time)
  end

  def new
    @schedule = Schedule.new
    session[:previous_url] = request.referer
  end

  def create
    @schedule = current_user.schedules.new(schedule_params)
    if @schedule.save(context: :create_or_update)
      # スケジュール開始時間からユーザーが設定した分数だけ前に、LINEメッセージの送信ジョブを追加
      job = SendLineMessageJob.set(wait_until: @schedule.start_time - @schedule.user.setting.notification_time*60).perform_later(@schedule.id)
      @schedule.update!(job_id: job.job_id, status: :to_be_sent)
      redirect_to session[:previous_url] ||= dashboards_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :new
    end
  end

  def edit
    @schedule = current_user.schedules.to_be_sent.find(params[:id])
  end

  def update
    @schedule = current_user.schedules.to_be_sent.find(params[:id])
    @schedule.assign_attributes(schedule_params)
    if @schedule.save(context: :create_or_update)

      # Sidekiqに登録されているLINEメッセージの送信ジョブを削除する
      ss = Sidekiq::ScheduledSet.new
      jobs = ss.select { |job| job.args[0]['job_id'] == @schedule.job_id }
      jobs.each(&:delete)

      # 新しくジョブを登録する
      job = SendLineMessageJob.set(wait_until: @schedule.start_time - @schedule.user.setting.notification_time*60).perform_later(@schedule.id)
      @schedule.update!(job_id: job.job_id)

      redirect_to schedules_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :edit
    end
  end

  def destroy
    @schedule = current_user.schedules.to_be_sent.find(params[:id])

    # Sidekiqに登録されているLINEメッセージの送信ジョブを削除する
    ss = Sidekiq::ScheduledSet.new
    jobs = ss.select { |job| job.args[0]['job_id'] == @schedule.job_id }
    jobs.each(&:delete)

    @schedule.destroy!
    redirect_to schedules_path, success: t('.success')
  end

  private

  def schedule_params
    params.require(:schedule).permit(:title, :body, :start_time, :end_time)
  end
end
