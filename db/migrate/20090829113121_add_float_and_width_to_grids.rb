class AddFloatAndWidthToGrids < ActiveRecord::Migration
  def self.up
    add_column :grids, :float, :string, :length => 1, :default => 'l'
    add_column :grids, :width, :integer, :default => 50
  end

  def self.down
    remove_column :grids, :float
    remove_column :grids, :width
  end
end
