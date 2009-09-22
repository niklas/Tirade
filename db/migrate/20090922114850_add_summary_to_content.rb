class AddSummaryToContent < ActiveRecord::Migration
  def self.up
    add_column :contents, :summary, :text
  end

  def self.down
    remove_column :contents, :summary
  end
end
