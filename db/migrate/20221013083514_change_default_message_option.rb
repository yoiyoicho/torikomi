class ChangeDefaultMessageOption < ActiveRecord::Migration[7.0]
  def change
    change_column_default :settings, :message_option, from: 0, to: 1
  end
end
