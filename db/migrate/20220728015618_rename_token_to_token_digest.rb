class RenameTokenToTokenDigest < ActiveRecord::Migration[7.0]
  def change
    rename_column :link_tokens, :token, :token_digest
  end
end
