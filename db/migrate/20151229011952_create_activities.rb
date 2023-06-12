class CreateActivities < ActiveRecord::Migration[4.2]
  def change
    create_table :exchanges do |t|
      t.datetime :event_date
      t.decimal :balance_initial, :precision => 8, :scale => 3
      t.decimal :balance_final, :precision => 8, :scale => 3
      t.string :description
      t.string :event_type
      t.decimal :amount, :precision => 8, :scale => 3
      t.string :spread

      t.timestamps
    end
  end
end
