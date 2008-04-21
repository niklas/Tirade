# == Schema Information
# Schema version: 6
#
# Table name: grids
#
#  id         :integer         not null, primary key
#  parent_id  :integer         
#  lft        :integer         
#  rgt        :integer         
#  yui :string(255)     
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
    'yui-u'  =>   'empty'
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

  def before_destroy
    children.each(&:destroy)
  end

  def after_destroy
    parent.andand.save
  end

  def self.new_by_yui(grid_class)
    new(:yui => grid_class)
  end

  def after_save
    auto_create_missing_children
  end

  def yui=(new_class)
    write_attribute(:yui,new_class)
    auto_create_missing_children unless new_record?
  end

  def add_child(child_grid=nil)
    self.save! if new_record?
    child_grid ||= self.class.new_by_yui('yui-u')
    child_grid.save!
    child_grid.move_to_child_of self
    self.save!
    child_grid
  end

  def visible_children
    children.first(ideal_children_count)
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
    classes << 'first' if self.is_first_child?
    classes << 'grid'
    classes.uniq.join(' ')
  end

  def is_first_child?
    self == self.parent.andand.visible_children.andand.first || false
  end

  protected
  def auto_create_missing_children
    while children.length < ideal_children_count
      add_child
    end
  end
end
