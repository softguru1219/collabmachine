class CreateBills < ActiveRecord::Migration[4.2]
  def change
    create_table :bills do |t|
      t.integer :worker_id
      t.decimal :amount
      t.integer :contract_id
      t.datetime :date_paid
      t.string :payment_method

      t.timestamps
    end
  end
end
