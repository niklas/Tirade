class RemoveDivisionColumnFromGrids < ActiveRecord::Migration
  def self.up
    remove_column :grids, :division
  end

  def self.down
    add_column :grids, :division, :string
  end
end
