class DashboardsController < ApplicationController
  def index
    @schedules = current_user.schedules
    @line_users = current_user.line_users
    @setting = current_user.setting
    @google_calendar_setting = current_user.google_calendar_setting
  end
end
