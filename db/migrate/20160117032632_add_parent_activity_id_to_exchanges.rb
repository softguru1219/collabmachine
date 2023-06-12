class AddParentActivityIdToExchanges < ActiveRecord::Migration[4.2]
  def self.up
    add_column :exchanges, :parent_exchange_id, :integer
    change_column :exchanges, :parent_exchange_id, :integer, after: :amount
  end

  def self.down
    remove_column :exchanges, :parent_exchange_id
  end
end
