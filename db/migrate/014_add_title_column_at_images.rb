class AddTitleColumnAtImages < ActiveRecord::Migration
  def self.up
    add_column :images, :title, :string
  end

  def self.down
    remove_column :images, :title
  end
end
