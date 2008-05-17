class AddOptionsToRenderings < ActiveRecord::Migration
  def self.up
    add_column :renderings, :options, :text
  end

  def self.down
    remove_column :renderings, :options
  end
end
