# == Schema Information
# Schema version: 20090809211822
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
#  width      :string(16)      
#  alignment  :string(8)       
#

class Page < ActiveRecord::Base
  acts_as_tree :order => 'position'
  include Tirade::ActiveRecord::CssClasses

  attr_protected :created_at, :updated_at

  acts_as_renderer
  acts_as_content :liquid => [
    :title, :url, :parent, :public_children, :trailing_path, :path, :slug, :root, :public_siblings, :lft, :rgt, :root?, :id, :is_child_of?
  ]
  has_fulltext_search :title, :url

  belongs_to :layout, :class_name => 'Grid', :foreign_key => 'layout_id'
  has_many :renderings
  # FIXME cannot do that because:
  # Cannot have a has_many :through association 'Page#contents' on the polymorphic object 'Content#content'
  # has_many :contents, :through => :renderings
  has_many :parts, :through => :renderings
  has_many :grids, :through => :renderings

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :parent_id
  validates_uniqueness_of :url, :allow_nil => true

  validates_format_of :width, :with => /\A\d+(px|em|ex|%)|auto\Z/, :allow_blank => true
  Alignments = %w(left center right)
  validates_inclusion_of :alignment, :in => Alignments, :allow_blank => true

  BlacklistesTitles = %w(manage themes)

  named_scope :all_except, lambda {|me|
    me.new_record? ? {} : {:conditions => ['id != ?',me.id]}
  }

  def validate
    errors.add(:title,'is not allowed here') if parent.andand.parent_id.nil? && BlacklistesTitles.include?(title.urlize)
  end

  def before_validation
    self.url = generated_url if url.blank?
  end

  def after_move
    self.url = generated_url 
  end

  def final_layout
    layout || parent.andand.final_layout
  end

  def final_alignment
    alignment.blank? ? parent.andand.final_alignment : alignment
  end

  def generated_url
    if !parent_id.nil?
      [parent.url, self.title.urlize].compact.join('/')
    elsif @move_to_new_parent_id.to_i != 0
      [Page.find_by_id(@move_to_new_parent_id).andand.url, title.urlize].compact.join('/')
    else
      ''
    end.sub(%r(^/),'')
  end

  def main_content
    Array( renderings.for_grid(biggest_grid).first.content ).first rescue nil
  end

  def biggest_grid
    grids.title_like('Content').first || grids.title_like('Main').first || grids.first
  end

  # Find all the renderings to show on this grid on this page
  # Grids may inherit renderings from parent page
  def renderings_for_grid(grid)
    rs = renderings.for_grid(grid)
    if rs.empty? && grid.inherit_renderings? && !root?
      parent.renderings_for_grid(grid)
    else
      rs
    end
  end

  def inherits_layout?
    layout_id.nil?
  end


  attr_accessor :trailing_path
  def self.find_by_path(path=[])
    page = nil
    path = path.dup
    trailing_path = []
    while page.nil? && !path.empty?
      url = path.collect(&:urlize).join('/')
      unless page = find_by_url(url)
        trailing_path.unshift path.pop.urlize
      end
    end
    page.trailing_path = trailing_path if page
    return page
  end

  def root?
    parent_id.nil? || root == self
  end

  def is_child_of?(other)
    other.url.starts_with?(other.url)
  end

  def path
    if root?
      []
    elsif parent.andand.root?
      [slug]
    else
      parent.path + [slug]
    end
  end

  def level
    root? ? 0 : url.count('/') + 1
  end

  def slug
    title.urlize
  end

  def public_children
    children.to_a
  end

  def public_siblings
    self_and_siblings.to_a
  end

  def title_unless_root
    parent_id ? title : nil
  end

  def title_with_url
    "#{title} (#{url})"
  end

  def label
    title_with_url
  end

  def url_with_trailing_path
    (path + (trailing_path || []) ).compact.join('/')
  end

  def render
    render_to_string(:inline => %Q[<%= render(:partial => 'pages/page', :object => page)  %>], :locals => { :page => self })
  end

  def style
    returning '' do |css|
      css << %Q~width: #{width.blank? ? 'auto' : width};~
      case final_alignment
      when 'center'
        css << %q~margin: 0 auto~
      when 'right'
        css << %q~margin: 0 0 0 auto~
      end
    end
  end

  def width
    if self[:width].blank? && parent
      parent.width
    else
      self[:width]
    end
  end

  attr_accessor :fresh
  def fresh?
    @fresh
  end
  after_create :set_freshness
  before_save :set_freshness_before_save
  private
  def set_freshness
    @fresh = true
  end

  def set_freshness_before_save
    @fresh = true if layout_id_changed?
  end


  def self.sample
    new(
      :title => 'Sample Page',
      :url => 'this/page/does/not/exist'
    )
  end
end
