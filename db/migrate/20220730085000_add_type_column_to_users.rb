class AddTypeColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :login_type, :integer, null: false, default: 0
    remove_index :users, :email
  end
end
