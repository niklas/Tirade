# == Schema Information
# Schema version: 20081120155111
#
# Table name: grids
#
#  id         :integer         not null, primary key
#  parent_id  :integer         
#  lft        :integer         
#  rgt        :integer         
#  yui        :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#  title      :string(255)     
#

class Grid < ActiveRecord::Base
  attr_protected :id, :created_at, :updated_at

  acts_as_nested_set 
  acts_as_renderer
  Types = {
    'yui-g'  =>   '50% - 50%',
    'yui-gb' =>	'33% - 33% - 33%',
    'yui-gc' =>	'66% - 33%',
    'yui-gd' =>	'33% - 66%',
    'yui-ge' =>	'75% - 25%',
    'yui-gf' =>	'25% - 75%',
    'yui-u'  =>   'single'
  }
  IdealChildrenCount = {
    'yui-g'  =>   2,
    'yui-gb' =>	3,
    'yui-gc' =>	2,
    'yui-gd' =>	2,
    'yui-ge' =>	2,
    'yui-gf' =>	2,
    'yui-u'  =>   0
  }
  validates_inclusion_of :yui, :in => Types

  has_many :pages, :foreign_key => 'layout_id'

  def after_destroy
    parent.andand.save
  end

  def self.new_by_yui(grid_class)
    new(:yui => grid_class)
  end

  after_save :wrap_children
  after_save :auto_create_missing_children

  def yui=(new_yui)
    yui_will_change!
    write_attribute('yui', new_yui)
    unless new_record? || !changes.empty?
      auto_create_missing_children
    end
    yui
  end

  def add_child(child_grid=nil)
    child_grid ||= self.class.new(:yui => 'yui-u')
    child_grid.save!
    child_grid.move_to_child_of self
    child_grid
  end

  def visible_children
    ideal_children_count > 0 ? children.first(ideal_children_count) : children
  end

  def ideal_children_count
    IdealChildrenCount[self.yui] || 2
  end

  # A wrapper to return the proper YUI class depending on +self+'s position
  # in the hierarchy
  def yuies
    classes = []
    classes << 'yui-u'
    classes << yui
    classes << 'horizontal' if yui =~ /yui-g.?/
    classes << 'first' if self.is_first_child?
    classes << 'grid'
    classes.uniq.join(' ')
  end

  def is_first_child?
    self == self.parent.andand.visible_children.andand.first || false
  end

  def name
    if 'yui-u' == self.yui
      if root?
        "root"
      else
        if parent.root?
          '100%'
        else
          parent.name.split(/[\s-]+/)[self_and_siblings.index(self)] || '100%'
        end
      end
    else
      Types[self.yui] || '[unknown]'
    end
  end

  def label
    [title,name].compact.join(' - ')
  end

  # Renders just the grid (without any contents)
  def render
    render_to_string(:inline => '<%= render_grid(grid) %>', :locals => {:grid => self})
  end

  #Renders the Grids with all the Renderings for that page
  def render_in_page(thepage)
    render_to_string(:inline => '<%= render_grid_in_page(grid,page) %>', :locals => {:grid => self, :page => thepage})
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
