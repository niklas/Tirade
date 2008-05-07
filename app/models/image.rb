# == Schema Information
# Schema version: 17
#
# Table name: images
#
#  id                 :integer         not null, primary key
#  image_file_name    :string(255)     
#  image_content_type :string(255)     
#  image_file_size    :integer         
#  created_at         :datetime        
#  updated_at         :datetime        
#  title              :string(255)     
#

# FIXME: Temporary location for the image styles configuration
CONFIG = {}
CONFIG[:thumbnail_size] = '60x60#'
CONFIG[:upload_images_path] = '/upload/'

class Image < ActiveRecord::Base
  has_attached_file :image,
                    :styles => {:thumbnail => CONFIG[:thumbnail_size]},
                    :path => ":rails_root/public#{CONFIG[:upload_images_path]}:attachment/:id/:style/:basename.:extension",
                    :url => "#{CONFIG[:upload_images_path]}:attachment/:id/:style/:basename.:extension"
  
  has_fulltext_search :title
  
  # validates_presence_of :image_file_name
  validates_attachment_presence :image
  
  before_create :generate_title
  
  def url
    image.url if image
  end
  
  def multiple_images=(images)
    images.each do |attributes|
      Image.create(attributes) unless attributes[:image].class.to_s == 'String'
    end
  end

  def custom_thumbnail_url(geom)
    thumb = Paperclip::Thumbnail::new(image, geom)
    tempfile = thumb.make
    geom = thumb.target_geometry.to_s
    scaled_name = 'custom' + geom 
    scaled_path = image.path(scaled_name)
    FileUtils.mkdir_p(File.dirname(scaled_path))
    tempfile.stream_to(scaled_path) unless File.exists?(scaled_path)
    image.url(scaled_name)
  end
  
  private
  def generate_title
    # Remove last extension
    title = self.image_file_name.split('.')
    title = title[0..-2].join
    self.title = title.humanize.titlecase
  end
end
