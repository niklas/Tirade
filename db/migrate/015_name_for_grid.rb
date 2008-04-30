class NameForGrid < ActiveRecord::Migration
  def self.up
    add_column :grids, :title, :string
  end

  def self.down
    remove_column :grids, :title
  end
end
