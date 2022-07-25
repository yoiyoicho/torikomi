class AddLinkTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :link_token, :string, limit: 255, unique: true
    add_column :users, :link_token_created_at, :timestamp
  end
end
