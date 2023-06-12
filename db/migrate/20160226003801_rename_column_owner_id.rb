class RenameColumnOwnerId < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :projects, :owner_id, :user_id
  end
  def self.down
    rename_column :projects, :user_id, :owner_id
  end
end
