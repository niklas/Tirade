# == Schema Information
# Schema version: 14
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
  # FIXME dynamic
  ValidContentTypes = [Content, Document, Image, NewsFolder, NewsItem]
  def self.valid_content_types
    ValidContentTypes
  end

  attr_accessible :position, :page, :grid, :content, :content_id, :content_type, :part, :part_id
  validates_presence_of :grid_id
  validates_presence_of :page_id
  validates_presence_of :content_type, :if => :content_id
  validates_inclusion_of :content_type, :in => ValidContentTypes.collect(&:to_s), :if => :content_id

  belongs_to :page
  belongs_to :grid
  belongs_to :content, :polymorphic => true
  belongs_to :part

  acts_as_list :scope => :grid_id


  has_finder :for_grid, lambda {|gr|
    {:conditions => ['renderings.grid_id = ?', gr.id], :order => 'renderings.position'}
  }

  has_finder :with_part, lambda {|part|
    {:conditions => ['renderings.part_id = ?', part.id], :order => 'renderings.position'}
  }

  def brothers_by_part
    page.renderings.with_part(self.part)
  end

  def options
    {}
  end

  def final_options
    options.merge(part.andand.options || {})
  end
end
