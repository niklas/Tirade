class MigrateContentFromNestedSetToTree < ActiveRecord::Migration
  def self.up
    Content.update_all('position=lft')
    remove_column :contents, :rgt
    remove_column :contents, :lft
  end

  def self.down
    add_column :contents, :rgt, :integer
    add_column :contents, :lft, :integer
  end
end
