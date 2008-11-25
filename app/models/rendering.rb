# == Schema Information
# Schema version: 20081120155111
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
#  options      :text            
#  assignment   :string(32)      default("fixed")
#

class Rendering < ActiveRecord::Base
  acts_as_renderer

  # For now, all associatable Conten Types should at least have a 'title' column
  def self.valid_content_types
    #ActiveRecord::Base.send(:subclasses).select do |k| 
    #  k.table_exists? &&
    #    k.columns.collect(&:name).include?('title') rescue false
    #end
    ([Content,Image,Video,YoutubeVideoCollection] + Content.valid_types).uniq
  end

  attr_accessible :position, :page, :grid, :content, :content_id, :content_type, :part, :part_id, :grid_id, :page_id, :options, :assignment
  validates_presence_of :grid_id
  validates_presence_of :page_id
  validates_presence_of :content_type, :if => :content_id


  belongs_to :page
  belongs_to :part

  belongs_to :grid
  def grid_id=(new_grid_id)
    @old_grid_id = grid_id
    self[:grid_id] = new_grid_id
  end
  def grid_changed?
    old_grid_id && (old_grid_id != grid_id)
  end
  attr_reader :old_grid_id

  Assignments = %w(fixed by_title_from_trailing_url).freeze unless defined?(Assignments)
  validates_inclusion_of :assignment, :in => Assignments, :allow_nil => true
  belongs_to :content, :polymorphic => true
  def trailing_path_of_page
    page.andand.trailing_path || []
  end
  def content_with_dynamic_assignments
    case assignment
    when 'by_title_from_trailing_url'
      if content_type && content_slug = trailing_path_of_page.first.andand.sluggify
        content_type.constantize.find_by_slug(content_slug)
      end
    else
      content_without_dynamic_assignments
    end
  end
  alias_method_chain :content, :dynamic_assignments

  acts_as_list :scope => :grid_id

  acts_as_custom_configurable :using => :options, :defined_by => :part

  named_scope :for_grid, lambda {|gr|
    {:conditions => ['renderings.grid_id = ?', gr.id], :order => 'renderings.position'}
  }

  named_scope :with_part, lambda {|part|
    {:conditions => ['renderings.part_id = ?', part.id], :order => 'renderings.position'}
  }

  named_scope :with_content, lambda {|content|
    {:conditions => ['renderings.content_id = ? AND renderings.content_type = ?', content.id, content.class.to_s], :order => 'renderings.position'}
  }

  def content_type=(new_content_type)
    write_attribute(:content_type, new_content_type.to_s) unless new_content_type.blank?
  end
  def content_id=(new_content_id)
    write_attribute(:content_id, new_content_id.to_i) unless new_content_id.to_i == 0
  end
  def has_content?
    !content.nil?
  rescue
    false
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
      part.andand.label|| '[brand new]',
      (has_content? ? content.title : nil)
    ].compact.join(' with ')
  end

  def brothers_by_part
    page.renderings.with_part(self.part)
  end

  def final_options
    options.merge(part.andand.options || {})
  end

  def render
    render_to_string(:inline => '<%= render_rendering(rendering) %>', :locals => {:rendering => self})
  end

end
