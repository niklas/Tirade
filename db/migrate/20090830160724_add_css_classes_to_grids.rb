class AddCssClassesToGrids < ActiveRecord::Migration
  def self.up
    add_column :grids, :css_classes, :string
  end

  def self.down
    remove_column :grids, :css_classes
  end
end
