class CreateLineUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :line_users do |t|
      t.string :line_user_id, null: false
      t.string :display_name, null: false
      t.string :picture_url

      t.timestamps
    end
  end
end
