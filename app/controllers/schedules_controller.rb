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
      SendLineMessageJob.perform_later(@schedule.id)
      redirect_to schedules_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :new
    end
  end

  def edit
    @schedule = current_user.schedules.find(params[:id])
  end

  def update
    @schedule = current_user.schedules.find(params[:id])
    if @schedule.update(schedule_params)
      redirect_to schedules_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :edit
    end
  end

  def destroy
    @schedule = current_user.schedules.find(params[:id])
    @schedule.destroy!
    redirect_to schedules_path, success: t('.success')
  end

  private

  def schedule_params
    params.require(:schedule).permit(:title, :body, :start_time, :end_time)
  end
end
