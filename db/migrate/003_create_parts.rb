class CreateParts < ActiveRecord::Migration
  def self.up
    create_table :parts do |t|
      t.string :name
      t.string :filename
      t.text :options
      t.text :preferred_types
      t.integer :subpart_id

      t.timestamps
    end
  end

  def self.down
    drop_table :parts
  end
end
