class AddPluralColumnToRenderings < ActiveRecord::Migration
  def self.up
    add_column :renderings, :plural, :boolean, :default => false
  end

  def self.down
    remove_column :renderings, :plural
  end
end
