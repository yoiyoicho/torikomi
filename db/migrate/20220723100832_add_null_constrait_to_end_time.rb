class AddNullConstraitToEndTime < ActiveRecord::Migration[7.0]
  def change
    change_column_null :schedules, :end_time, false
  end
end
