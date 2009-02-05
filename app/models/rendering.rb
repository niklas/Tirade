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
  serialize :scope, HashWithIndifferentAccess
  def scope
    self[:scope] ||= HashWithIndifferentAccess.new
  end

  # For now, all associatable Conten Types should at least have a 'title' column
  def self.valid_content_types
    Tirade::ActiveRecord::Content.classes
  end

  attr_accessible :position, :page, :grid, :content, :content_id, :content_type, :part, :part_id, :grid_id, :page_id, :options, :assignment, :scope
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

  Assignments = %w(none fixed by_title_from_trailing_url scope).freeze unless defined?(Assignments)

  validates_inclusion_of :assignment, :in => Assignments, :allow_nil => true
  belongs_to :content, :polymorphic => true
  def trailing_path_of_page
    page.andand.trailing_path || []
  end
  def content_with_dynamic_assignments
    case assignment
    when 'none'
      false
    when 'by_title_from_trailing_url'
      if content_type && content_slug = trailing_path_of_page.first.andand.sluggify
        content_type.constantize.find_by_slug(content_slug)
      end
    when 'scope'
      if content_type
        find_content_by_scope(scope)
      end
    else
      content_without_dynamic_assignments
    end
  end
  alias_method_chain :content, :dynamic_assignments

  def find_content_by_scope(thescope=self.scope)
    klass = content_type.constantize
    # HACK if no scope is specified, we must not return the klass
    Tirade::ActiveRecord::Content::Scopes.map(&:to_sym).inject(klass.scoped({:conditions => '1=1'})) do |records,valid_scope|
      if thescope.has_key?(valid_scope)
        records.send!(valid_scope,thescope[valid_scope])
      else
        records
      end
    end.to_a
  end

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
    write_attribute(:content_type, new_content_type.to_s) unless new_content_type.to_s.blank?
  end
  def content_id=(new_content_id)
    write_attribute(:content_id, new_content_id.to_i) unless new_content_id.to_i == 0
  end
  def has_content?
    !content.nil? && (!content == false)
  rescue
    false
  end

  def validate
    if self.content_id
      unless self.class.valid_content_types.find {|ct| ct <= self.content_type.constantize}
        errors.add(:content_type, "Invalid Content Type: #{self.content_type} (allowed: #{self.class.valid_content_types.to_sentence})") 
      end
    end
  end

  def label
    [
      part.andand.label || '[brand new]',
      (has_content? ? content.title : nil)
    ].compact.join(' with ')
  end

  def brothers_by_part
    page.renderings.with_part(self.part)
  end

  def final_options
    options.to_hash.
      merge(context).
      merge(part.andand.options || {})
  end

  def render
    render_to_string(:inline => '<%= render_rendering(rendering) %>', :locals => {:rendering => self})
  end

  def context_in_registers(assigns={})
    {
      :registers => { 'rendering_context' => context(assigns) }
    }
  end

  def context(assings={})
    {
      'page' => page
    }
  end

end
