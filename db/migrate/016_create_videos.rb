class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos, :id => false, :primary_key => false do |t|
      t.integer :id
      t.string :title
      t.integer :artist_id
      t.string :artist_name
      t.text :urls
      t.string :image_url

      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
