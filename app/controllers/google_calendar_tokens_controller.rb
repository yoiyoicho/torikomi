class GoogleCalendarTokensController < ApplicationController
  def destroy
    google_calendar_token = current_user.google_calendar_token
    google_calendar_token.destroy!
    redirect_back_or_to dashboards_path, success: 'Googleカレンダーとの連携を解除しました'
  end
end