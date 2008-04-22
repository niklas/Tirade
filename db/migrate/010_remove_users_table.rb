class RemoveUsersTable < ActiveRecord::Migration
  def self.up
    drop_table :users
  end

  def self.down
    create_table :users do |t|
      t.string :name
      t.string :password_hash, :limit => 40
      t.string :password_salt, :limit => 40
      t.datetime :verified_at
      t.string :email
      t.string :remember_me, :limit => 40

      t.timestamps
    end    
  end
end
