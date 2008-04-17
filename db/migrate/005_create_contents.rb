class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.string :title
      t.text :description
      t.text :body
      t.string :type
      t.string :state
      t.integer :owner_id
      t.datetime :published_at
      t.integer :position
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt

      t.timestamps
    end
  end

  def self.down
    drop_table :contents
  end
end
