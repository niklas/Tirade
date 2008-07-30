class MigrateStylishPermissionsTo001 < ActiveRecord::Migration
  def self.up
    migrate_plugin 'stylish_permissions', 1
  end

  def self.down
    migrate_plugin 'stylish_permissions', 0
  end
end
