# == Schema Information
# Schema version: 20090711174603
#
# Table name: renderings
#
#  id               :integer         not null, primary key
#  page_id          :integer         
#  content_id       :integer         
#  part_id          :integer         
#  grid_id          :integer         
#  position         :integer         
#  created_at       :datetime        
#  updated_at       :datetime        
#  content_type     :string(255)     
#  options          :text            
#  assignment       :string(32)      default("fixed")
#  scope_definition :text            
#  plural           :boolean         
#

class Rendering < ActiveRecord::Base
  acts_as_renderer
  serialize :scope_definition, Hash
  def scope_definition
    self[:scope_definition] ||= Hash.new
  end

  # For now, all associatable Conten Types should at least have a 'title' column
  def self.valid_content_types
    Tirade::ActiveRecord::Content.classes
  end

  attr_accessible :position, :page, :grid, :content, :content_id, :content_type, :part, :part_id, :grid_id, :page_id, :options, :assignment, :scope_definition, :scope
  validates_presence_of :grid_id
  validates_presence_of :page_id
  validates_presence_of :content_type, :if => :content_id

  belongs_to :page
  belongs_to :part

  belongs_to :grid

  named_scope :for_page, lambda {|page|
    if page
      {:conditions => {:page_id => page.id}}
    else
      {}
    end
  }
  attr_accessor :modifications
  before_save do |rendering|
    rendering.modifications = rendering.changes.dup
  end

  def grid_modified?
    modifications.has_key?('grid') || modifications.has_key?('grid_id')
  end

  def old_grid
    modifications && ( modifications['grid'].andand.last || (gid = modifications['grid_id'].andand.last && Grid.find_by_id(gid)) )
  end

  def singular?
    !plural?
  end

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
      plural? ? content_by_scope : content_by_scope.first
    else
      content_without_dynamic_assignments
    end
  end
  alias_method_chain :content, :dynamic_assignments

  # returns a SearchLogic::Search
  def scope
    if content_type
      @scope ||= content_type.constantize.search(scope_definition)
    else
      raise "no content_type set"
    end
  end

  def scope=(new_scope)
    @scope = nil
    self.scope_definition = new_scope
  end

  def content_by_scope(thescope=self.scope)
    scope.all
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

  def content_title
    if has_content?
      content.is_a?(Array) ? content.map(&:title).join(', ') : content.title
    end
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
      content_title
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
      'page' => page,
      'trailing_path_of_page' => trailing_path_of_page
    }
  end

end
