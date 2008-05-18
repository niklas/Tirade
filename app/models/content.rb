# == Schema Information
# Schema version: 17
#
# Table name: contents
#
#  id           :integer         not null, primary key
#  title        :string(255)     
#  description  :text            
#  body         :text            
#  type         :string(255)     
#  state        :string(255)     
#  owner_id     :integer         
#  published_at :datetime        
#  position     :integer         
#  parent_id    :integer         
#  lft          :integer         
#  rgt          :integer         
#  created_at   :datetime        
#  updated_at   :datetime        
#

class Content < ActiveRecord::Base
  acts_as_nested_set
  include LazyNestedSet

  # TODO how to handle the #type correctly .. and when?
  attr_protected :type, :state, :owner_id, :owner, :published_at, :created_at, :updated_at

  validates_presence_of :title


  # FIXME please spec
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'

  has_fulltext_search :title, :description, :body
  acts_as_pictureable

  def self.sample
    new(
      :title => "Example Content Record",
      :description => "A brief but solid description",
      :body => "A looooong and beautiful body four your Example Content"
    )
  end

  def validate
    errors.add(:type, 'illegal Type') unless self.class <= Content
  end

  def self.valid_types
    [Document, Folder, NewsFolder, NewsItem]
  end

end
