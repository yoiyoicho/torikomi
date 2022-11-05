class RemoveAccessTokenColumnFromGoogleCalendarTokens < ActiveRecord::Migration[7.0]
  def change
    remove_column :google_calendar_tokens, :access_token, :string
    remove_column :google_calendar_tokens, :expires_at, :datetime
  end
end
