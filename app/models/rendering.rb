# == Schema Information
# Schema version: 20090809211822
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
  include Tirade::ActiveRecord::CssClasses
  # For now, all associatable Conten Types should at least have a 'title' column
  def self.valid_content_types
    Tirade::ActiveRecord::Content.classes
  end

  attr_accessible :position, :page, :grid, :content, :content_id, :content_type, :part, :part_id, :grid_id, :page_id, :options, :assignment, :scope_definition, :scope, :css_classes, :css_classes_list, :hide_if_trailing_path_not_blank, :hide_expired_content
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
  named_scope :for_content, lambda {|content|
    if content
      {:conditions => {:content_id => content.id, :content_type => content.class_name }}
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

  def plural?
    part.andand.plural?
  end

  Assignments = %w(none fixed by_title_from_trailing_url scope).freeze unless defined?(Assignments)

  validates_inclusion_of :assignment, :in => Assignments
  belongs_to :content, :polymorphic => true
  def trailing_path_of_page
    page.andand.trailing_path || []
  end

  def hidden?
    (hide_if_trailing_path_not_blank? && !trailing_path_of_page.blank?) ||
      (assignment == 'by_title_from_trailing_url' && trailing_path_of_page.blank?)
  end

  def content_with_dynamic_assignments
    case assignment
    when 'none'
      false
    when 'by_title_from_trailing_url'
      if content_type
        content_type.constantize.find_by_path(trailing_path_of_page)
      end
    when 'scope'
      content_by_scope
    else
      content_without_dynamic_assignments
    end
  end
  alias_method_chain :content, :dynamic_assignments

  def content_class
    if content_type
      content_type.constantize
    else
      raise "no content_type set"
    end
  end
  # returns a SearchLogic::Search
  def scope
    content_class.search(normalized_scope_definition)
  end

  def scope=(new_scope)
    @scope = nil
    self.scope_definition = new_scope
  end

  def content_by_scope(thescope=self.scope)
    thescope.current_scope.delete(:order)
    if hide_expired_content?
      thescope.not_expired(true).order(ordering.order).all
    else
      thescope.order(ordering.order).all
    end
  end

  def scope_definition
    read_attribute(:scope_definition) || Hash.new
  end

  def scopings
    normalized_scope_definition.map do |name, val|
      Scoping.new_by_name(name.to_s, val)
    end.flatten.compact
  end

  class Scoping < Struct.new(:attribute, :comparison, :value)
    SplitName = /^([\w_]+)_(#{Searchlogic::NamedScopes::Conditions::PRIMARY_CONDITIONS.join('|')})$/

    def self.new_by_name(name, value)
      if name =~ SplitName
        new($1, $2, value)
      end
    end

    def name
      "#{attribute}_#{comparison}"
    end

    def method_missing(method_name, *args, &block)
      value
    end
  end

  def ordering
    defs = normalized_scope_definition
    Ordering.new_by_name(defs[:order]) || Ordering.new('created_at', 'descend')
  end

  class Ordering < Struct.new(:attribute, :direction)

    def self.new_by_name(name)
      if name =~ /^(ascend|descend)_by_([\w_]+)$/
        new($2, $1)
      end
    end

    def order
      "#{direction}_by_#{attribute}"
    end
  end

  # we save it like it came from the form, so we have to fix it for searchlogic
  def normalized_scope_definition
    given = scope_definition.dup
    filtered = {}.with_indifferent_access

    if attribute = given.delete(:order_attribute)
      direction = given.delete(:order_direction) || 'ascend'
      filtered[:order] = %Q[#{direction}_by_#{attribute}]
    end

    given.select {|k,v| v.is_a?(Hash)}.each do |att, comps|
      comps.each do |comp, val|
        filtered["#{att}_#{comp}".to_sym] = val
      end
    end
    given.delete_if {|k,v| v.is_a?(Hash)}

    filtered.merge(given)
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
  def content_type
    read_attribute(:content_type) || part.andand.preferred_types.andand.first
  end
  def has_content_type?
    !read_attribute(:content_type).blank?
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
    returning '' do |l|
      l << "#{part.title}" if part
      if content_title.blank?
        l << ' (blank)' if needs_content?
      else
        l << ": #{content_title}"
      end
    end
  end
  alias_method :title, :label

  def brothers_by_part
    page.renderings.with_part(self.part)
  end

  def brothers_on_page
    page.renderings.content_type_equals(content_type)
  end

  def final_options
    returning options.to_hash do |o|
      o.reverse_merge! part.andand.options_hash || {}
      o.merge! context
      o.merge!( {'current_locale' => I18n.locale.to_s})
      o.merge! content_association_options || {}
    end
  end

  def content_association_options
    if part.singular? && has_content? && content.is_a?(ActiveRecord::Base)
      association_name = options.to_hash_with_defaults['association'] || :children
      association = content_class.reflections[association_name.to_sym]
      if association
        items = content.send(association_name)
        if trailing_path_of_page.blank?
          { 'children' => items }
        else
          { 'children' => items, 'child' => items.find_by_path(trailing_path_of_page) }
        end
      end
    end
  end

  def needs_content?
    if part
      !part.static?
    else
      true
    end
  end

  def drop_acceptions
    returning [] do |accept|
      if part.nil?
        accept << 'Part' 
        if !has_content? && needs_content?
          if content_type.blank?
            accept << Tirade::ActiveRecord::Content.classes
          else
            accept << content_type 
          end
        end
      else
        accept << part.supported_types unless part.supported_types.blank?
      end
    end.flatten.compact.map(&:to_s).uniq
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
