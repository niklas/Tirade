# == Schema Information
# Schema version: 12
#
# Table name: images
#
#  id                 :integer         not null, primary key
#  image_file_name    :string(255)     
#  image_content_type :string(255)     
#  image_file_size    :integer         
#  created_at         :datetime        
#  updated_at         :datetime        
#

# FIXME: Temporary location for the image styles configuration
CONFIG = {}
CONFIG[:thumbnail_size] = '100x100#'
CONFIG[:upload_images_path] = '/public/upload/'

class Image < ActiveRecord::Base
  has_attached_file :image,
                    :styles => {:thumbnail => CONFIG[:thumbnail_size]},
                    :default_style => :thumbnail,
                    :path => ":rails_root#{CONFIG[:upload_images_path]}:attachment/:id/:style/:basename.:extension"

  alias_attribute :title, :image_file_name
  has_fulltext_search :image_file_name
end
