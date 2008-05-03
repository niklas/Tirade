class NewsFolder < Content
  validates_uniqueness_of :title, :message => 'There is already a Newsfolder with this title'
  has_many :items, :foreign_key => 'parent_id', :class_name => 'NewsItem'

  def self.sample
    s = new(
      :title => 'Example News',
      :description => 'Look away! NOW!',
      :body => 'Read more papers on the toil.. in the bathroom.'
    )
    3.times { s.items << wanted_item_class.sample }
  end

  def wanted_item_class
    NewsItem
  end
end
