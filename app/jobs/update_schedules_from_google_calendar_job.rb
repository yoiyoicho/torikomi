class UpdateSchedulesFromGoogleCalendarJob < ApplicationJob
  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets'

  queue_as :default

  def perform
    auth_client = get_auth_client
    User.all.each do |user|
      if user.google_calendar_token.present?
        set_service = GoogleCalendar::ScheduleSetService.new(user, auth_client)
        set_service.call
      end
    end
  end

  private

  def get_auth_client
    client_secrets = Google::APIClient::ClientSecrets.new({
      "web":{
        "client_id":ENV['GOOGLE_CALENDAR_CLIENT_ID'],
        "auth_uri":"https://accounts.google.com/o/oauth2/auth",
        "token_uri":"https://oauth2.googleapis.com/token",
        "client_secret":ENV['GOOGLE_CALENDAR_CLIENT_SECRET'],
        "redirect_uris":[api_google_calendar_callback_url]
      }
    })
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      scope: 'https://www.googleapis.com/auth/calendar.readonly',
      additional_parameters: {
        access_type: 'offline',
        prompt: 'consent',
        session: false
      }
    )
    auth_client
  end
end