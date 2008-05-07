class JustOneUrlForVideo < ActiveRecord::Migration
  def self.up
    remove_column :videos, :urls
    add_column :videos, :url, :string
  end

  def self.down
    add_column :videos, :urls, :text
    remove_column :videos, :url
  end
end
