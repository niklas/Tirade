# == Schema Information
# Schema version: 1
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
  acts_as_nested_set 
  Types = {
    'yui-g'  =>   '1/2 - 1/2',
    'yui-gb' =>	'1/3 - 1/3 - 1/3',
    'yui-gc' =>	'2/3 - 1/3',
    'yui-gd' =>	'1/3 - 2/3',
    'yui-ge' =>	'3/4 - 1/4',
    'yui-gf' =>	'1/4 - 3/4',
    'yui-u'  =>   'single'
  }
  validates_inclusion_of :grid_class, :in => Types

  def self.new_by_grid_class(grid_class)
    new(:grid_class => grid_class)
  end

  def add_child(child_grid=nil)
    self.save if new_record?
    child_grid ||= self.class.new_by_grid_class('yui-u')
    child_grid.save!
    child_grid.move_to_child_of self
    child_grid
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
    classes.join(' ')
  end

  def is_first_child?
    self == self.parent.andand.children.andand.first
  end
end
