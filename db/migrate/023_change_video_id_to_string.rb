class ChangeVideoIdToString < ActiveRecord::Migration
  def self.up
    change_column :videos, :id, :string
  end

  def self.down
    change_column :videos, :id, :integer
  end
end
