class MakePagesUnNested < ActiveRecord::Migration
  def self.up
    add_column :pages, 'position', :integer
    Page.update_all 'position=lft'
    remove_column :pages, :lft
    remove_column :pages, :rgt
  end

  def self.down
    add_column :pages, :lft, :integer
    add_column :pages, :rgt, :integer
    Page.update_all 'lft=position'
    remove_column :pages, 'position'
  end
end
