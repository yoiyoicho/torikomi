class AddStatusAndOtpToLineUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :line_users, :status, :integer, null: false, default: 0
  end
end
