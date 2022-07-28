class CreateLinkTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :link_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false, unique: true

      t.timestamps
    end
  end
end
