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
      t.integer :start_time_hour, null: false, default:0
      t.integer :start_time_min, null: false, default: 0
      t.integer :end_time_hour, null: false, default: 23
      t.integer :end_time_min, null: false, default: 50
      t.timestamps
    end
  end
end
