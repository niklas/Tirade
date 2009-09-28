class CreatePaperclippings < ActiveRecord::Migration
  def self.up
    create_table :paperclippings do |t|
      t.integer :asset_id
      t.integer :content_id
      t.string  :content_type
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :paperclippings
  end
end
