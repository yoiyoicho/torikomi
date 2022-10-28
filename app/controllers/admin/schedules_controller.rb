class Admin::SchedulesController < Admin::ApplicationController
  def index
    @schedules = Schedule.all
  end
end