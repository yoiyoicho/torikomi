class AddUniquenessConstraintToLineUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :line_users, :line_user_id, unique: true
  end
end
