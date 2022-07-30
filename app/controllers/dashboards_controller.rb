class DashboardsController < ApplicationController
  def index
    @schedules = current_user.schedules
    @line_users = current_user.line_users
    @setting = current_user.setting
  end
end
