class AddHideIfTrailingPathNotBlankToRenderings < ActiveRecord::Migration
  def self.up
    add_column :renderings, :hide_if_trailing_path_not_blank, :boolean, :default => false
  end

  def self.down
    remove_column :renderings, :hide_if_trailing_path_not_blank
  end
end
