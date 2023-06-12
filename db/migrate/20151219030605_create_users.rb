class CreateUsers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :users do |t|
      t.boolean :active,      default: true
      t.string :first_name
      t.string :last_name
      t.string :email
      t.float  :balance
      t.string :role,         default: 'member'
      t.string :access_level, default: 'member'
      t.string :password_hash
      t.string :password_salt
      t.string :password


      t.timestamps
    end
  end
  def self.down
    drop_table :users
  end
end
