class AddExpireAtToContent < ActiveRecord::Migration
  def self.up
    # FIXME please tell your children about that
    add_column :contents, :expires_at, :datetime
  end

  def self.down
    remove_column :contents, :expires_at
  end
end
