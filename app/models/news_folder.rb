# == Schema Information
# Schema version: 20090412210854
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

class NewsFolder < Content
  validates_uniqueness_of :title, :message => 'There is already a Newsfolder with this title'
  has_many :items, :foreign_key => 'parent_id', :class_name => 'NewsItem'
  acts_as_content :liquid => [:title, :description, :slug]

  def self.sample
    s = new(
      :title => 'Example News',
      :description => 'Look away! NOW!',
      :body => 'Read more papers on the toil.. in the bathroom.'
    )
    3.times { s.items << wanted_item_class.sample }
    s
  end

  def self.wanted_item_class
    NewsItem
  end
  def wanted_item_class
    self.class.wanted_item_class
  end
end
