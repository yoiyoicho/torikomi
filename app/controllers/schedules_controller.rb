class SchedulesController < ApplicationController
  before_action :set_schedule, only: %i(edit update destroy)
  before_action :verify_access, only: %i(edit update destroy)

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
    redirect_to dashboards_path, error: t('defaults.invalid_access') unless @schedule.default?
  end

  def update
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

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end

  def verify_access
    redirect_to dashboards_path, error: t('defaults.invalid_access') unless current_user.my_object?(@schedule)
  end
end
