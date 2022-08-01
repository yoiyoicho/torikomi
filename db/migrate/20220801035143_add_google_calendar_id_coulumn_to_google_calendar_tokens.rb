class AddGoogleCalendarIdCoulumnToGoogleCalendarTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :google_calendar_tokens, :google_calendar_id, :string, null: false
  end
end
