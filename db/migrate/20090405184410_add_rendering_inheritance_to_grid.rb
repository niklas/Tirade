class AddRenderingInheritanceToGrid < ActiveRecord::Migration
  def self.up
    add_column :grids, :inherit_renderings, :boolean, :default => false
  end

  def self.down
    remove_column :grids, :inherit_renderings
  end
end
