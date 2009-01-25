class AddScopeToRendering < ActiveRecord::Migration
  def self.up
    add_column :renderings, :scope, :text
  end

  def self.down
    remove_column :renderings, :scope
  end
end
