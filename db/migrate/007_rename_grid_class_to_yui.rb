class RenameGridClassToYui < ActiveRecord::Migration
  def self.up
    rename_column :grids, :grid_class, :yui
  end

  def self.down
    rename_column :grids, :yui, :grid_class
  end
end
