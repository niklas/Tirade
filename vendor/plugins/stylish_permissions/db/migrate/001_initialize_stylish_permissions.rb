class InitializeStylishPermissions < ActiveRecord::Migration
  def self.up
   create_table "groups" do |t|
     t.string   "name"
     t.integer  "group_id"
     t.timestamps
   end

   create_table "groups_roles", :id => false do |t|
     t.integer "group_id"
     t.integer "role_id"
   end

   create_table "groups_users", :id => false do |t|
     t.integer "group_id"
     t.integer "user_id"
   end

   create_table "permissions" do |t|
     t.string   "app_controller"
     t.string   "app_method"
     t.boolean  "processed"
     t.timestamps
   end

   create_table "permissions_roles", :id => false do |t|
     t.integer "role_id"
     t.integer "permission_id"
   end

   create_table "roles" do |t|
     t.string   "name"
     t.string   "short_name"
     t.boolean  "is_public"
     t.timestamps
   end

   create_table "user_roles", :id => false do |t|
     t.integer  "user_id"
     t.integer  "role_id"
     t.timestamps
   end
  end

  def self.down
   drop_table "groups"
   drop_table "groups_roles"
   drop_table "groups_users"
   drop_table "permissions"
   drop_table "permissions_roles"
   drop_table "roles"
   drop_table "user_roles"
  end
end
