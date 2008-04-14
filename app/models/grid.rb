# == Schema Information
# Schema version: 2
#
# Table name: grids
#
#  id         :integer         not null, primary key
#  parent_id  :integer         
#  lft        :integer         
#  rgt        :integer         
#  grid_class :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Grid < ActiveRecord::Base
  attr_protected :id, :created_at, :updated_at

  acts_as_nested_set 
  Types = {
    'yui-g'  =>   '1/2 - 1/2',
    'yui-gb' =>	'1/3 - 1/3 - 1/3',
    'yui-gc' =>	'2/3 - 1/3',
    'yui-gd' =>	'1/3 - 2/3',
    'yui-ge' =>	'3/4 - 1/4',
    'yui-gf' =>	'1/4 - 3/4',
    'single'  =>  '100%',
    'yui-u'  =>   'empty'
  }
  IdealChildrenCount = {
    'yui-g'  =>   2,
    'yui-gb' =>	3,
    'yui-gc' =>	2,
    'yui-gd' =>	2,
    'yui-ge' =>	2,
    'yui-gf' =>	2,
    'single' =>	1,
    'yui-u'  =>   0
  }
  validates_inclusion_of :grid_class, :in => Types

  def after_destroy
    parent.andand.save
  end

  def before_save
    auto_yui_class!
  end

  def self.new_by_grid_class(grid_class)
    new(:grid_class => grid_class)
  end

  def add_child(child_grid=nil)
    self.save! if new_record?
    child_grid ||= self.class.new_by_grid_class('yui-u')
    child_grid.save!
    child_grid.move_to_child_of self
    self.save!
    child_grid
  end

  def visible_children
    children.first(ideal_children_count)
  end

  def ideal_children_count
    IdealChildrenCount[self.grid_class] || 0
  end

  # A wrapper to return the proper YUI class depending on +self+'s position
  # in the hierarchy
  def grid_classes
    classes = []
    if self.children.empty?
      classes << 'yui-u'
    else
      classes << grid_class
    end
    classes << 'first' if self.is_first_child?
    classes << 'grid'
    classes.join(' ')
  end

  def is_first_child?
    self == self.parent.andand.children.andand.first
  end

  def auto_yui_class!
    if ideal_children_count != children.size && new_class = self.auto_yui_class
      self.grid_class = new_class
    end
  end

  protected
  def auto_yui_class
    actual_count = self.children.length
    IdealChildrenCount.sort.find {|name,count| count == actual_count}.andand.first
  end
end
