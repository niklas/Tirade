class AddReplacementToGrid < ActiveRecord::Migration
  def self.up
    add_column :grids, :replacement_id, :integer
  end

  def self.down
    remove_column :grids, :replacement_id
  end
end
