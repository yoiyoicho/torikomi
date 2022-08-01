class CreateGoogleCalendarSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :google_calendar_settings do |t|
      t.belongs_to :user, index: { unique: true }, null: false, foreign_key: true
      t.boolean :monday, null: false, default: 0
      t.boolean :tuesday, null: false, default: 0
      t.boolean :wednesday, null: false, default: 0
      t.boolean :thursday, null: false, default: 0
      t.boolean :friday, null: false, default: 0
      t.boolean :saturday, null: false, default: 0
      t.boolean :sunday, null: false, default: 0
      t.timestamp :start_time, null: false, default: Time.zone.now.beginning_of_day
      t.timestamp :end_time, null: false, default: Time.zone.now.end_of_day

      t.timestamps
    end
  end
end
