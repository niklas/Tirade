class AddPluralFlagToParts < ActiveRecord::Migration
  def self.up
    add_column :parts, :plural, :boolean
  end

  def self.down
    remove_column :parts, :plural
  end
end
