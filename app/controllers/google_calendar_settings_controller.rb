class GoogleCalendarSettingsController < ApplicationController
#   before_action :set_google_calendar_setting

  def show
  end

#   def edit
#     session[:previous_url] = request.referer
#   end
#  
#  def update
#     if @google_calendar_setting.update(google_calendar_setting_params)
#       redirect_to session[:previous_url] ||= dashboards_path, success: t('.success')
#     else
#       flash.now[:error] = t('.fail')
#       render :edit, status: :unprocessable_entity
#     end
#   end
# 
#   private
# 
#   def set_google_calendar_setting
#     @google_calendar_setting = current_user.google_calendar_setting
#   end
# 
#   def google_calendar_setting_params
#     params.require(:google_calendar_setting).permit(:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :start_time_hour, :start_time_min, :end_time_hour, :end_time_min)
#   end
end
