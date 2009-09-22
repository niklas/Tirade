class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string :title
      t.text :description
      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size

      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
