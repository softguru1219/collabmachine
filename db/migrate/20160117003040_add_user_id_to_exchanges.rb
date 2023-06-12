class AddUserIdToExchanges < ActiveRecord::Migration[4.2]
  def self.up
    add_column :exchanges, :user_id, :integer
    change_column :exchanges, :user_id, :integer, after: :event_date
  end

  def self.down
    remove_column :exchanges, :user_id
  end
end
