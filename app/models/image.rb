# FIXME: Temporary location for the image styles configuration
CONFIG = {}
CONFIG[:thumbnail_size] = '100x100#'

class Image < ActiveRecord::Base
  has_attached_file :image,
                    :styles => {:thumbnail => CONFIG[:thumbnail_size]},
                    :default_style => :thumbnail
end
