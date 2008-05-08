class CreatePicturization < ActiveRecord::Migration
  def self.up
    create_table :picturizations do |t|
      t.integer :image_id
      t.integer :pictureable_id
      t.string  :pictureable_type
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :picturizations
  end
end
