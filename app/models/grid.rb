# == Schema Information
# Schema version: 20090809211822
#
# Table name: grids
#
#  id                 :integer         not null, primary key
#  parent_id          :integer         
#  lft                :integer         
#  rgt                :integer         
#  created_at         :datetime        
#  updated_at         :datetime        
#  title              :string(255)     
#  inherit_renderings :boolean         
#  division           :string(255)     
#

class Grid < ActiveRecord::Base
  attr_protected :id, :created_at, :updated_at

  acts_as_nested_set 
  acts_as_renderer
  NameByDivision = {
    '50-50'    =>   '50% - 50%',
    '33-33-33' =>	'33% - 33% - 33%',
    '33-66'    =>	'33% - 66%',
    '66-33'    =>	'66% - 33%',
    '75-25'    =>	'75% - 25%',
    '25-75'    =>	'25% - 75%',
    '62-38'    => '62% - 38%',
    '38-62'    => '38% - 62%',
    'leaf'     => 'content',
    'wrap'     => 'Wrapper'
  }
  IdealChildrenCount = {
    '50-50'   =>  2,
    '33-33-33'=>	3,
    '75-25'   =>	2,
    '25-75'   =>	2,
    '33-66'   =>	2,
    '66-33'   =>	2,
    '38-62'   =>	2,
    '62-38'   =>	2,
    'leaf'    =>  0,
    'wrap'    =>  0
  }
  Divisions = [
    '50-50', '75-25', '25-75',
    '33-33-33', '33-66', '66-33',
    '38-62', '62-38',
    'leaf', 'wrap'
  ]

  # YAML

  Widths = [100, 50, 25, 75, 66, 33, 38, 62]
  validates_presence_of :width
  validates_inclusion_of :width, :in => Widths

  Floats = %w(l r)
  validates_inclusion_of :float, :in => Floats, :allow_blank => true, :allow_nil => true

  validates_inclusion_of :division, :in => Divisions, :allow_blank => true

  def yaml_column_class
    "c#{width}#{float || 'l'}" unless wrapper?
  end

  def yaml_sub_class
    returning [] do |css|
      css << "subc#{float}"
      css << 'subcolumns' unless empty?
      css << 'leaf' if children.empty?
    end.flatten.uniq.join(' ')
  end

  def wrapper?
    width == 100
  end

  def empty?
    children.empty? && renderings.empty?
  end

  # Dividing
  attr_accessor :division

  after_save :apply_division
  def apply_division
    if division
      case division
      when '33-33-33'
        ensure_children_for_division(division, %w(l l r))
      when /-/
        ensure_children_for_division(division, %w(l r))
      end
      division = nil
    end
  end

  # Make sure the first 2/3 children apply to the given division
  def ensure_children_for_division(division, floats)
    widths = division.split('-').map(&:to_i)
    return if widths.length < floats.length
    widths.zip(floats, children).each do |width, float, child|
      if child
        child.update_attributes!(:width => width, :float => float)
      else
        child = self.class.create!(:width => width, :float => float)
        child.move_to_child_of self
      end
    end
  end



  has_many :pages, :foreign_key => 'layout_id'
  has_many :renderings
  def renderings_count
    renderings.count
  end

  # Rendering inheritance over pages
  def renderings_for_page(page)
    page.renderings_for_grid(self)
  end

  def after_destroy
    if parent
      parent.save
      renderings.update_all("grid_id = #{parent.id}")
    end
  end

  after_save :wrap_children

  def add_child(child_grid=nil)
    child_grid ||= self.class.new(:division => 'leaf')
    child_grid.save!
    child_grid.move_to_child_of self
    child_grid
  end

  def position
    self_and_siblings.index(self)
  end

  def title
    unless (t = read_attribute(:title)).blank?
      t
    else
      if children.empty?
        "#{width} %"
      else
        children.map(&:title).join(' | ')
      end
    end
  end

  def icon_name
    if children.empty?
      'grid-single'
    else
      'grid'
    end
  end

  # Renders just the grid (without any contents)
  def render
    render_to_string(:inline => '<%= render_grid(grid) %>', :locals => {:grid => self})
  end

  #Renders the Grids with all the Renderings for that page
  def render_in_page(thepage)
    render_to_string(:inline => '<%= render_grid_in_page(grid,page) %>', :locals => {:grid => self, :page => thepage})
  end

  def explode!
    transaction do 
      we = self.self_and_siblings
      common_children = we.collect(&:children).flatten
      #common_renderings = self.self_and_siblings.collect(&:renderings).compact
      par = self.parent or raise("cannot explode root")
      par.update_attributes! :yui => 'yui-u'
      common_children.each do |child|
        child.move_to_child_of par.id
      end
      we.each(&:destroy)
    end

  end

  attr_reader :page_id
  def page_id=(page_id)
    @page_id = page_id.to_i
  end
  def current_page
    page_id && Page.find_by_id(page_id)
  end
  after_create do |grid|
    if page = grid.current_page
      page.layout = grid
      page.save!
    end
  end

  attr_writer :child_id
  protected

  def wrap_children
    if root? && !@child_id.nil? && (thechild = Grid.find_by_id(@child_id)) 
      @child_id = nil
      Grid.transaction do
        thechild.pages.each do |page|
          page.layout = self
          page.save!
        end
        thechild.move_to_child_of self
      end
    end
    true
  end
end
