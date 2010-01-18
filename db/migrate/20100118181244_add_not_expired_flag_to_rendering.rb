class AddNotExpiredFlagToRendering < ActiveRecord::Migration
  def self.up
    add_column :renderings, :hide_expired_content, :boolean
  end

  def self.down
    remove_column :renderings, :hide_expired_content
  end
end
