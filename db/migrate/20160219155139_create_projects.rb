class CreateProjects < ActiveRecord::Migration[4.2]
  def change
    create_table :projects do |t|
      t.integer :owner_id
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
