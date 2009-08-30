class AddCssClassesToRenderings < ActiveRecord::Migration
  def self.up
    add_column :renderings, :css_classes, :string
  end

  def self.down
    remove_column :renderings, :css_classes
  end
end
