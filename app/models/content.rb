# == Schema Information
# Schema version: 20090809211822
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
#  slug         :string(255)     default("")
#

class Content < ActiveRecord::Base
  acts_as_tree :order => 'position'

  # TODO how to handle the #type correctly .. and when?
  attr_protected :type, :state, :owner_id, :owner, :published_at, :created_at, :updated_at

  liquid_methods :title, :description, :body, :slug
  validates_presence_of :title
  markup :description, :body


  # FIXME please spec
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'

  def self.browse(params={})
    search(params[:search].andand[:term]).child_of(params[:parent_id]).paginate(:page => params[:page])
  end

  named_scope :child_of, lambda {|p| p.nil? ? {} : {:conditions => {:parent_id => p.is_a?(Content) ? p.id : p}}}
  has_fulltext_search :title, :description, :body
  acts_as_pictureable
  acts_as! :pictureable

  has_slug :prepend_id => false

  def self.sample
    new(
      :title => "Example Content Record",
      :description => "A brief but solid description",
      :body => "A looooong and *beautiful* body for your Example Content"
    )
  end

  def validate
    errors.add(:type, 'illegal Type') unless self.class <= Content
  end

  def self.valid_types
    [Document, Folder, NewsFolder, NewsItem]
  end

end
