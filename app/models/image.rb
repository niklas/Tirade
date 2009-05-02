# == Schema Information
# Schema version: 20081120155111
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
                    :styles => {
                      :thumbnail => CONFIG[:thumbnail_size],
                      :icon => '80x16'
                    },
                    :path => ":rails_root/public#{CONFIG[:upload_images_path]}:attachment/:id/:style/:basename.:extension",
                    :url => "#{CONFIG[:upload_images_path]}:attachment/:id/:style/:basename.:extension"
  
  has_fulltext_search :title, :image_file_name
  acts_as_content :liquid => [:title, :image_file_name]

  def self.attachment_names
    [:image]
  end
  
  # validates_presence_of :image_file_name
  validates_attachment_presence :image
  
  before_create :generate_title

  def icon_path
    image.url(:icon)
  end
  
  def url
    image.andand.url
  end

  def multiple_images=(images)
    @multiple_images ||= []
    images.each do |attributes|
      @multiple_images << Image.create(attributes) unless attributes[:image].is_a?(String)
    end
  end

  def multiple_images
    @multiple_images ||= []
  end

  def scale_to(geom='50x50')
    Paperclip::Thumbnail::new(image, geom)
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

  def self.sample
    new :title => 'Sample Image'
  end

  class LiquidDropClass
    def url
      @url || @object.url
    end
    def url=(new_url)
      @url = new_url
    end
  
  end
  
  private
  def generate_title
    # Remove last extension
    title = self.image_file_name.split('.')
    title = title[0..-2].join
    self.title = title.humanize.titlecase
  end
end
