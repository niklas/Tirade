class DefinedOptionsForPart < ActiveRecord::Migration
  def self.up
    add_column :parts, :defined_options, :text
  end

  def self.down
    remove_column :parts, :defined_options
  end
end
