class AddSlugsToContent < ActiveRecord::Migration
  def self.up
    add_column :contents, :slug, :string, :default => ''
  end

  def self.down
    remove_column :contents, :slug
  end
end
