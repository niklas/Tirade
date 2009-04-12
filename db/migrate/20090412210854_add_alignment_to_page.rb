class AddAlignmentToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :alignment, :string, :limit => 8
  end

  def self.down
    remove_column :pages, :alignment
  end
end
