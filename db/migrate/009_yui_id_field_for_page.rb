class YuiIdFieldForPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :yui, :string, :limit => 10
  end

  def self.down
    remove_column :pages, :yui
  end
end
