class AddAssignmentToRendering < ActiveRecord::Migration
  def self.up
    add_column :renderings, :assignment, :string, :limit => 32, :default => 'fixed'
  end

  def self.down
    remove_column :renderings, :assignment
  end
end
