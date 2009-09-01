class AddExtraWidthToGrids < ActiveRecord::Migration
  def self.up
    add_column :grids, :extra_width, :string, :limit => 10
  end

  def self.down
    remove_column :grids, :extra_width
  end
end
