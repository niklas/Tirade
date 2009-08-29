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
  Divisions = {
    '50-50' => %w(c50l c50r),
    '75-25' => %w(c75l c25r),
    '25-75' => %w(c25l c75r),
    '33-33-33' => %w(c33l c33X c33r),
    '33-66'   =>	%w(c33l c66r),
    '66-33'   =>	%w(c66l c33r),
    '38-62'   =>	%w(c38l c62r),
    '62-38'   =>	%w(c62l c38r),
    'leaf' => [],
    'wrap' => []
  }

  # YAML

  Widths = [100, 50, 25, 75, 33, 28, 62]
  validates_presence_of :width
  validates_inclusion_of :width, :in => Widths

  Floats = %w(l r)
  validates_inclusion_of :float, :in => Floats, :allow_blank => true

  def yaml_class
    "c#{width}#{float || 'l'}"
  end

  def yaml_content_class
    "subc#{float}"
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
  after_save :auto_create_missing_children

  def division=(new_division)
    division_will_change!
    write_attribute('division', new_division)
    unless new_record? || !changes.empty?
      auto_create_missing_children
    end
    division
  end

  def add_child(child_grid=nil)
    child_grid ||= self.class.new(:division => 'leaf')
    child_grid.save!
    child_grid.move_to_child_of self
    child_grid
  end

  def visible_children
    ideal_children_count > 0 ? children.first(ideal_children_count) : children
  end

  def ideal_children_count
    IdealChildrenCount[division] || 2
  end

  def is_first_child?
    self == self.parent.andand.visible_children.andand.first || false
  end

  def name
    if 'leaf' == self.division
      if root?
        "root"
      else
        if parent.name == 'root'
          '100%'
        else
          parent.name.andand.split(/[\s-]+/).andand[position] || 'Leaf'
        end
      end
    else
      NameByDivision[division] || '[unknown]'
    end
  end

  def is_wrapper?
    division == 'wrap'
  end

  def position
    self_and_siblings.index(self)
  end

  def own_css
    case division
    when 'wrap'
      []
    when 'leaf'
      if !position
        %w(root leaf)
      elsif self_and_siblings.count <= 2
        [position == 0 ? 'subcl' : 'subcr', 'leaf']
      else
        [%w[subcl subc subcr][position], 'leaf']
      end
    else
      %w(subcolumns)
    end
  end

  def wrapper_css
    if root?
      ''
    else
      parent.children_css[position]
    end
  end

  def children_css
    Divisions[division] || raise("illegal division: #{division}")
  end

  def visible_children_with_css
    visible_children.zip(children_css)
  end

  def label
    [title,name].compact.join(' - ')
  end

  def icon_name
    case division
    when 'leaf'
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

  def wrap!(new_yui='yui-u')
    self.class.create(:yui => new_yui, :child_id => self.id)
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
  def auto_create_missing_children
    while children.length < ideal_children_count
      add_child
    end
    true
  end

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
