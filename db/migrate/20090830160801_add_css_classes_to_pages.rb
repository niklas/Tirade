class AddCssClassesToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :css_classes, :string
  end

  def self.down
    remove_column :pages, :css_classes
  end
end
