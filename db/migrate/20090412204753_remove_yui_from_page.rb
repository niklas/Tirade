class RemoveYuiFromPage < ActiveRecord::Migration
  def self.up
    remove_column :pages, :yui
  end

  def self.down
    add_column :pages, :yui, :string
  end
end
