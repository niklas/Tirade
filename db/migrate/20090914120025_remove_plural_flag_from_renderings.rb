class RemovePluralFlagFromRenderings < ActiveRecord::Migration
  def self.up
    remove_column :renderings, :plural
  end

  def self.down
    add_column :renderings, :plural, :boolean
  end
end
