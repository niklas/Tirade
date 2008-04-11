class CreateGrids < ActiveRecord::Migration
  def self.up
    create_table :grids do |t|
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.string :grid_class

      t.timestamps
    end
  end

  def self.down
    drop_table :grids
  end
end
