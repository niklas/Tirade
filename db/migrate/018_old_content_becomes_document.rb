class OldContentBecomesDocument < ActiveRecord::Migration
  def self.up
    Content.update_all("type = 'Document'", "type = 'Content' or type IS NULL")
  end

  def self.down
  end
end
