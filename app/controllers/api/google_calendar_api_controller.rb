class Api::GoogleCalendarApiController < ApplicationController
  # 下記のドキュメントをもとに実装
  # https://developers.google.com/identity/protocols/oauth2/web-server#ruby_1
  # https://googleapis.dev/ruby/google-api-client/v0.20.1/Google/APIClient/ClientSecrets.html
  # https://googleapis.dev/ruby/google-api-client/latest/Google/Apis/CalendarV3/CalendarService.html
  # https://www.rubydoc.info/github/google/signet/Signet/OAuth2/Client

  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets'

  before_action :set_auth_client

  def authorize
    auth_uri = @auth_client.authorization_uri
    redirect_to auth_uri, allow_other_host: true
  end

  def callback
    if params[:code].present?
      @auth_client.code = params[:code]
      @auth_client.fetch_access_token!

      google_calendar_token = GoogleCalendarToken.find_or_initialize_by(user: current_user)
      google_calendar_token.assign_attributes(access_token: @auth_client.access_token, refresh_token: @auth_client.refresh_token, expires_at: @auth_client.expires_at)

      if google_calendar_token.save
        get_schedules_from_google_calendar
        redirect_to dashboards_path, success: 'Googleカレンダーと連携しました'
      else
        redirect_to dashboards_path, error: 'Googleカレンダーと連携できませんでした'
      end
    else
      redirect_to dashboards_path, error: 'Googleカレンダーと連携できませんでした'
    end
  end

  def update
    if current_user.google_calendar_token.present?
      get_schedules_from_google_calendar(current_user.google_calendar_token)
      redirect_to dashboards_path, success: 'Googleカレンダーからスケジュールを取得しました'
    else
      redirect_to dashboards_path, error: 'Googleカレンダーからスケジュールを更新できませんでした'
    end
  end

  def get_schedules_from_google_calendar(google_calendar_token = nil)
    if google_calendar_token.present?
      @auth_client.refresh_token =  google_calendar_token[:refresh_token]
      if google_calendar_token.expires_at < Time.zone.now
        @auth_client.refresh!
        google_calendar_token.update!(access_token: @auth_client.access_token, expires_at: @auth_client.expires_at)
      else
        @auth_client.access_token = google_calendar_token[:access_token]
      end
    end
    @calendar = Google::Apis::CalendarV3::CalendarService.new
    @calendar.authorization = @auth_client
    binding.pry
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