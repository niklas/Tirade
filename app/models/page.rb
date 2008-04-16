class Page < ActiveRecord::Base
  acts_as_nested_set

  belongs_to :layout, :class_name => 'Grid', :foreign_key => 'layout_id'

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :parent_id
  validates_uniqueness_of :url


  def final_layout
    layout || parent.andand.layout
  end
end
