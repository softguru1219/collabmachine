class CreateContracts < ActiveRecord::Migration[4.2]
  def change
    create_table :contracts do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :title
      t.text :description
      t.text :terms
      t.decimal :rate, precision: 16, scale: 2

      t.timestamps
    end
  end
end
