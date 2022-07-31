class CreateGoogleCalendarTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :google_calendar_tokens do |t|
      t.belongs_to :user, index: { unique: true }, null: false, foreign_key: true
      t.string :access_token, null: false
      t.string :refresh_token, null: false

      t.timestamps
    end
  end
end
