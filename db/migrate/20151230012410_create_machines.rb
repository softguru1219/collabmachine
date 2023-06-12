class CreateMachines < ActiveRecord::Migration[4.2]
  def change
    create_table :machines do |t|
      t.decimal :balance,  :precision => 8, :scale => 3
      t.decimal :balance_contrib,  :precision => 8, :scale => 3
      t.decimal :balance_stash,  :precision => 8, :scale => 3
      t.decimal :volume,  :precision => 8, :scale => 3

      t.timestamps
    end
  end
end
