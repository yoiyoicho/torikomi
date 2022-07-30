class Api::GoogleCalendarApiController < ApplicationController
  require 'google/apis/calendar_v3'

  def authorize
    endpoint = 'https://accounts.google.com/o/oauth2/v2/auth'
    client_id = ENV['GOOGLE_CLIENT_ID']
    redirect_uri = CGI.escape(api_google_calendar_callback_url)
    response_type = 'code'
    scope = CGI.escape('https://www.googleapis.com/auth/calendar.readonly')
    request_url = endpoint + "?scope=#{scope}" + "&response_type=#{response_type}" + "&redirect_uri=#{redirect_uri}" + "&client_id=#{client_id}"
    redirect_to request_url, allow_other_host: true
  end

  def callback
    if params[:code].present?
      # auth_client.code = params[:code]
      # auth_client.fetch_access_token!
      # client = Google::Apis::CalendarV3::CalendarService.new
      # client.authorization =
      # redirect_to dashboards_path, success: 'Googleカレンダーと連携しました'
      redirect_to dashboards_path, success: 'Googleカレンダーと連携しました'
    else
      redirect_to dashboards_path, error: 'エラーです'
    end
  end
end