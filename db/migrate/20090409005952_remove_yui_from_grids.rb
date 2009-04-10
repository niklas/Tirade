class RemoveYuiFromGrids < ActiveRecord::Migration
  def self.up
    remove_column :grids, :yui
  end

  def self.down
    add_column :grids, :yui, :string
  end
end
