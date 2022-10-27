class SchedulesController < ApplicationController

  def index
    @schedules = current_user.schedules.order(:start_time)
  end

  def new
    @schedule = Schedule.new
  end

  def create
    @schedule = current_user.schedules.new(schedule_params)
    if @schedule.save
      set_service = Schedule::JobSetService.new(@schedule)
      set_service.call
      redirect_to schedules_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @schedule = current_user.schedules.default.find(params[:id])
  end

  def update
    @schedule = current_user.schedules.find(params[:id])
    @schedule.assign_attributes(schedule_params)
    if @schedule.save

      destroy_service = Schedule::JobDestroyService.new(@schedule)
      destroy_service.call

      set_service = Schedule::JobSetService.new(@schedule)
      set_service.call

      redirect_to schedules_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule = current_user.schedules.find(params[:id])

    destroy_service = Schedule::JobDestroyService.new(@schedule)
    destroy_service.call

    @schedule.destroy!
    redirect_to schedules_path, success: t('.success')
  end

  private

  def schedule_params
    if params[:schedule].present?
      # 編集フォームからのリクエスト
      params.require(:schedule).permit(:title, :body, :start_time, :end_time, :status)
    else
      # 「送信予約」「送信予約取消」ボタンからのリクエスト
      params.permit(:status)
    end
  end
end
