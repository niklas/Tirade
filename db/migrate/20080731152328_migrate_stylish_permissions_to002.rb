class MigrateStylishPermissionsTo002 < ActiveRecord::Migration
  def self.up
    migrate_plugin 'stylish_permissions', 2
  end

  def self.down
    migrate_plugin 'stylish_permissions', 1
  end
end
