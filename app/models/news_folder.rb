class NewsFolder < Content
  validates_uniqueness_of :title, :message => 'There is already a Newsfolder with this title'
  has_many :items, :foreign_key => 'parent_id', :class_name => 'NewsItem'

  def wanted_item_class
    NewsItem
  end
end
