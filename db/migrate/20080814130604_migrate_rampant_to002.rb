class MigrateRampantTo002 < ActiveRecord::Migration
  def self.up
    migrate_plugin 'rampant', 2
  end

  def self.down
    migrate_plugin 'rampant', 0
  end
end
