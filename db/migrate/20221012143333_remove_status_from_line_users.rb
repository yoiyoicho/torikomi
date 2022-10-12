class RemoveStatusFromLineUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :line_users, :status, :integer
  end
end
