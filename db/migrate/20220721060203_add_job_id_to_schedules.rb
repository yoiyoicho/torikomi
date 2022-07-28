class AddJobIdToSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :schedules, :job_id, :string, null: false, default: ''
  end
end
