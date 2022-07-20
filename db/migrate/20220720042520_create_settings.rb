class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.belongs_to :user, index: { unique: true }, null: false, foreign_key: true
      t.integer :message_option, null: false, default: 0
      t.string :message_text, limit: 255
      t.integer :notification_time, null: false, default: 0

      t.timestamps
    end
  end
end
