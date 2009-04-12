class AddWidthToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :width, :string, :limit => 16
  end

  def self.down
    remove_column :pages, :width
  end
end
