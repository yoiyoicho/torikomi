class Api::GoogleCalendarApiController < ApplicationController
  # 下記のドキュメントをもとに実装
  # https://developers.google.com/identity/protocols/oauth2/web-server#ruby_1
  # https://googleapis.dev/ruby/google-api-client/v0.20.1/Google/APIClient/ClientSecrets.html
  # https://googleapis.dev/ruby/google-api-client/latest/Google/Apis/CalendarV3/CalendarService.html
  # https://www.rubydoc.info/github/google/signet/Signet/OAuth2/Client
  # 関連する処理は、app/services/google_calendar/以下を参照のこと

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

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = @auth_client

      google_calendar_token = GoogleCalendarToken.find_or_initialize_by(user: current_user)
      google_calendar_token.assign_attributes(access_token: @auth_client.access_token, refresh_token: @auth_client.refresh_token, expires_at: @auth_client.expires_at, google_calendar_id: service.get_calendar('primary').id)

      if google_calendar_token.save
        redirect_back_or_to dashboards_path, success: t('.success')
      else
        redirect_back_or_to dashboards_path, error: t('.fail')
      end
    else
      redirect_back_or_to dashboards_path, error: t('.fail')
    end
  end

  def update
    if current_user.google_calendar_token.present?
      set_service = GoogleCalendar::ScheduleSetService.new(current_user, @auth_client)
      set_service.call
      redirect_to dashboards_path, success: t('.success')
    else
      redirect_to dashboards_path, error: t('.fail')
    end
  end

  private

  def set_auth_client
    client_secrets = Google::APIClient::ClientSecrets.new({
      "web":{
        "client_id":ENV['GOOGLE_CALENDAR_CLIENT_ID'],
        "auth_uri":"https://accounts.google.com/o/oauth2/auth",
        "token_uri":"https://oauth2.googleapis.com/token",
        "client_secret":ENV['GOOGLE_CALENDAR_CLIENT_SECRET'],
        "redirect_uris":[api_google_calendar_callback_url]
      }
    })
    @auth_client = client_secrets.to_authorization
    @auth_client.update!(
      scope: 'https://www.googleapis.com/auth/calendar.readonly',
      additional_parameters: {
        access_type: 'offline',
        prompt: 'consent',
        session: false
      }
    )
  end
end