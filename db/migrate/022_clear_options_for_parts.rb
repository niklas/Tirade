class ClearOptionsForParts < ActiveRecord::Migration
  def self.up
    # we may not use them
    Part.update_all("options = '--- {}\n'")
  end

  def self.down
  end
end
