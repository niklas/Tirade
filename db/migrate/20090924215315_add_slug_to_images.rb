class AddSlugToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :slug, :string
  end

  def self.down
    remove_column :images, :slug
  end
end
