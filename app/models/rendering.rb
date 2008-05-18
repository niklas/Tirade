# == Schema Information
# Schema version: 17
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
  acts_as_renderer

  # For now, all associatable Conten Types should at least have a 'title' column
  def self.valid_content_types
    #ActiveRecord::Base.send(:subclasses).select do |k| 
    #  k.table_exists? &&
    #    k.columns.collect(&:name).include?('title') rescue false
    #end
    ([Content,Image,Video] + Content.valid_types).uniq
  end

  attr_accessible :position, :page, :grid, :content, :content_id, :content_type, :part, :part_id, :grid_id, :page_id, :options
  validates_presence_of :grid_id
  validates_presence_of :page_id
  validates_presence_of :content_type, :if => :content_id

  belongs_to :page
  belongs_to :grid
  belongs_to :content, :polymorphic => true
  belongs_to :part

  acts_as_list :scope => :grid_id

  acts_as_custom_configurable :using => :options, :defined_by => :part

  has_finder :for_grid, lambda {|gr|
    {:conditions => ['renderings.grid_id = ?', gr.id], :order => 'renderings.position'}
  }

  has_finder :with_part, lambda {|part|
    {:conditions => ['renderings.part_id = ?', part.id], :order => 'renderings.position'}
  }

  def content_type=(new_content_type)
    write_attribute(:content_type, new_content_type.to_s) unless new_content_type.blank?
  end
  def content_id=(new_content_id)
    write_attribute(:content_id, new_content_id.to_i) unless new_content_id.to_i == 0
  end
  def has_content?
    !content_type.blank? && content_id.to_i != 0
  end

  def validate
    if self.content_id
      unless self.class.valid_content_types.collect(&:to_s).include?(self.content_type)
        errors.add(:content_type, "Invalid Content Type: #{self.content_type}") 
      end
    end
  end

  def label
    [
      part.label,
      (has_content? ? content.title : nil)
    ].compact.join(' with ')
  end

  def brothers_by_part
    page.renderings.with_part(self.part)
  end

  def final_options
    options.merge(part.andand.options || {})
  end

  def content_type=(new_content_type)
    write_attribute(:content_type, new_content_type.classify)
  end

  def render
    render_to_string(:inline => '<%= render_rendering(rendering) %>', :locals => {:rendering => self})
  end
end
