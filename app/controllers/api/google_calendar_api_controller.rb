class Api::GoogleCalendarApiController < ApplicationController
  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets'

  before_action :set_auth_client

  # 下記のドキュメントをもとに実装
  # https://developers.google.com/identity/protocols/oauth2/web-server#ruby_1
  # https://googleapis.dev/ruby/google-api-client/latest/Google/Apis/CalendarV3/CalendarService.html

  def authorize
    auth_uri = @auth_client.authorization_uri
    redirect_to auth_uri, allow_other_host: true
  end

  def callback
    if params[:code].present?
      @auth_client.code = params[:code]
      @auth_client.fetch_access_token!
      @calendar = Google::Apis::CalendarV3::CalendarService.new
      @calendar.authorization = @auth_client
      redirect_to dashboards_path, success: 'Googleカレンダーと連携しました'
    else
      redirect_to dashboards_path, error: 'Googleカレンダーと連携できませんでした'
    end
  end

  private

  def set_auth_client
    client_secrets = Google::APIClient::ClientSecrets.load('config/google_calendar_client_secrets.json')
    @auth_client = client_secrets.to_authorization
    @auth_client.update!(
      scope: 'https://www.googleapis.com/auth/calendar.readonly',
      additional_parameters: {
        access_type: 'offline'
      }
    )
  end
end