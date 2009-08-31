class AddDescriptionToParts < ActiveRecord::Migration
  def self.up
    add_column :parts, :description, :text
  end

  def self.down
    remove_column :parts, :description
  end
end
