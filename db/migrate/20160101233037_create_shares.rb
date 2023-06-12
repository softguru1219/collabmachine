class CreateShares < ActiveRecord::Migration[4.2]
  def change
    create_table :shares do |t|
      t.integer :user_id
      t.integer :activity_id
      t.decimal :proportion, precision: 16, scale: 2
      t.string :description

      t.timestamps
    end
  end
end
