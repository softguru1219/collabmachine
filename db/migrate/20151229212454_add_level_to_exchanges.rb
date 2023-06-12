class AddLevelToExchanges < ActiveRecord::Migration[4.2]
  def self.up
    add_column :exchanges, :level, :string, default: 'machine'

    change_column :exchanges, :level, :string, after: :id
  end
  def self.down
    remove_column :exchanges, :level
  end
end
