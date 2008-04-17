class CreateRenderings < ActiveRecord::Migration
  def self.up
    create_table :renderings do |t|
      t.integer :page_id
      t.integer :content_id
      t.integer :part_id
      t.integer :grid_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :renderings
  end
end
