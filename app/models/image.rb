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
CONFIG[:upload_images_path] = '/public/upload/'

class Image < ActiveRecord::Base
  has_attached_file :image,
                    :styles => {:thumbnail => CONFIG[:thumbnail_size]},
                    :default_style => :thumbnail,
                    :path => ":rails_root#{CONFIG[:upload_images_path]}:attachment/:id/:style/:basename.:extension"

  
  has_fulltext_search :title
end
