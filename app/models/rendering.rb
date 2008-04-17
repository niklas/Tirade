# == Schema Information
# Schema version: 6
#
# Table name: renderings
#
#  id         :integer         not null, primary key
#  page_id    :integer         
#  content_id :integer         
#  part_id    :integer         
#  grid_id    :integer         
#  position   :integer         
#  created_at :datetime        
#  updated_at :datetime        
#

class Rendering < ActiveRecord::Base
end
