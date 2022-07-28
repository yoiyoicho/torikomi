class AddStatusToSchedule < ActiveRecord::Migration[7.0]
  def change
    add_column :schedules, :status, :integer, null: false, default: 0
  end
end
