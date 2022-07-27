class CreateUserLineUserRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :user_line_user_relationships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :line_user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
