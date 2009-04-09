class AddDevisionToGrids < ActiveRecord::Migration
  def self.up
    add_column :grids, :division, :string, :length => 8
  end

  def self.down
    remove_column :grids, :divisions
  end
end
