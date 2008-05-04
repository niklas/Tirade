# == Schema Information
# Schema version: 14
#
# Table name: pages
#
#  id         :integer         not null, primary key
#  title      :string(255)     
#  url        :string(255)     
#  parent_id  :integer         
#  lft        :integer         
#  rgt        :integer         
#  layout_id  :integer         
#  created_at :datetime        
#  updated_at :datetime        
#  yui        :string(10)      
#

class Page < ActiveRecord::Base
  acts_as_nested_set

  attr_protected :created_at, :updated_at

  acts_as_renderer

  belongs_to :layout, :class_name => 'Grid', :foreign_key => 'layout_id'
  has_many :renderings
  # FIXME cannot do that because:
  # Cannot have a has_many :through association 'Page#contents' on the polymorphic object 'Content#content'
  # has_many :contents, :through => :renderings
  has_many :parts, :through => :renderings
  has_many :grids, :through => :renderings

  validates_presence_of :title
  validates_presence_of :yui
  validates_uniqueness_of :title, :scope => :parent_id
  validates_uniqueness_of :url, :allow_nil => true

  # TODO yui form parent

  Types = {
    'doc'  =>   '750px',
    'doc2'  =>   '950px',
    'doc3'  =>   '100%',
    'doc4'  =>   '974px',
    'custom-doc'  =>   'Custom'
  }
  def yui_name
    Types[yui] || 'custom'
  end
  BlacklistesTitles = %w(manage themes)

  has_finder :all_except, lambda {|me|
    {:conditions => ['id != ?',me.id]}
  }

  def validate
    errors.add(:title,'is not allowed here') if parent.andand.parent_id.nil? && BlacklistesTitles.include?(title.urlize)
  end

  def before_validation
    unless self.class.rebuilding? || lft.nil? || rgt.nil?
      self.url = generated_url 
    end
    self.yui ||= 'doc'
  end

  def final_layout
    layout || parent.andand.final_layout
  end

  def generated_url
    self_and_ancestors.collect(&:title_unless_root).compact.collect(&:urlize).join('/')
  end

  def wanted_parent_id
    self.read_attribute(:parent_id)
  end

  def wanted_parent_id=(new_parent_id)
    if new_parent = self.class.find_by_id(new_parent_id)
      transaction do
        self.save!
        self.move_to_child_of new_parent
        self.save!
      end
    end
  end

  def title_unless_root
    parent_id ? title : nil
  end

  @@rebuilding = false
  def self.rebuild_with_status!
    @@rebuilding = true
    rebuild_without_status!
    @@rebuilding = false
  end
  def self.rebuilding?
    @@rebuilding
  end
  class << self
    alias_method_chain :rebuild!, :status
  end

  def render
    render_to_string(:inline => '<%= render_page(page)  %>', :locals => { :page => self })
  end

end
