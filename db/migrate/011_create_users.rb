class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.string :login, :email, :remember_token
      t.string :crypted_password,          :limit => 40
      t.string :password_reset_code,       :limit => 40
      t.string :salt,                      :limit => 40      
      t.string :activation_code,           :limit => 40
      t.datetime :remember_token_expires_at, :activated_at, :deleted_at
      t.string :state, :null => :no, :default => 'passive'

      t.timestamps
    end
  end

  def self.down
    drop_table "users"
  end
end
