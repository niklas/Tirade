# == Schema Information
# Schema version: 14
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
                    :default_style => :thumbnail,
                    :path => ":rails_root/public#{CONFIG[:upload_images_path]}:attachment/:id/:style/:basename.:extension",
                    :url => "#{CONFIG[:upload_images_path]}/:attachment/:id/:style/:basename.:extension"
  
  has_fulltext_search :title
  
  before_create :generate_title
  
  private
  def generate_title
    # Remove last extension
    title = self.image_file_name.split('.')
    title = title[0..-2].join
    self.title = title.humanize.titlecase
  end
end
