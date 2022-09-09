class AddSentAtToSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :schedules, :sent_at, :datetime
  end
end
