class ContentTypeForRenderingAssociation < ActiveRecord::Migration
  def self.up
    add_column :renderings, :content_type, :string
    Rendering.update_all("content_type = 'Content'")
  end

  def self.down
    remove_column :renderings, :content_type
  end
end
