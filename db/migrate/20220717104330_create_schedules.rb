class CreateSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :schedules do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false, limit: 255
      t.string :body, limit: 65535
      t.timestamp :start_time, null: false
      t.timestamp :end_time

      t.timestamps
    end
  end
end
