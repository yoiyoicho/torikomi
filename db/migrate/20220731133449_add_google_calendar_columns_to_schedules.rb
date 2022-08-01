class AddGoogleCalendarColumnsToSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :schedules, :resource_type, :integer, null: false, default: 0
    add_column :schedules, :i_cal_uid, :string
  end
end
