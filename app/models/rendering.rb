# == Schema Information
# Schema version: 12
#
# Table name: renderings
#
#  id           :integer         not null, primary key
#  page_id      :integer         
#  content_id   :integer         
#  part_id      :integer         
#  grid_id      :integer         
#  position     :integer         
#  created_at   :datetime        
#  updated_at   :datetime        
#  content_type :string(255)     
#

class Rendering < ActiveRecord::Base
  attr_accessible :position, :page, :grid, :content, :part
  validates_presence_of :grid_id
  validates_presence_of :page_id

  belongs_to :page
  belongs_to :grid
  belongs_to :content, :polymorphic => true
  belongs_to :part

  has_finder :for_grid, lambda {|gr|
    {:conditions => ['grid_id = ?', gr.id]}
  }

  def options
    {}
  end
end
