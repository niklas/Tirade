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
  attr_accessible :position
  validates_presence_of :grid_id
  validates_presence_of :page_id

  belongs_to :page
  belongs_to :grid
  belongs_to :content
  belongs_to :part
end
