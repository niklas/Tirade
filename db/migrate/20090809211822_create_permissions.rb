class CreatePermissions < ActiveRecord::Migration
  def self.up
    remove_column :permissions, :app_controller
    remove_column :permissions, :app_method
    remove_column :permissions, :processed
    add_column :permissions, :name, :string

		create_table :permissions_user_groups, :id => false do |t|
      t.integer :permission_id
      t.integer :user_group_id
    end
  end

  def self.down
		drop_table :permissions_user_groups
    remove_column :permissions, :name
    add_column :permissions, "app_controller", :string  
    add_column :permissions, "app_method"    , :string  
    add_column :permissions, "processed"     , :boolean 
  end
end
