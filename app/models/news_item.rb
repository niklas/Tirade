class NewsItem < Content
  belongs_to :newsfolder, :foreign_key => 'parent_id', :class_name => 'NewsFolder'

  has_finder :last, lambda { |num|
    {:order => 'published_at DESC, updated_at DESC', :limit => num}
  }

  has_finder :between, lambda { |from,to|
    {:conditions => ['published_at BETWEEN ? AND ?', from, to], :order => 'published_at DESC, updated_at DESC'}
  }

  # stolen from typo (http://www.typosphere.org/trac/browser/trunk/app/models/article.rb:217)
  has_finder :by_date, lambda { |year,month,day|
    from = Time.mktime(year, month || 1, day || 1)
    to = from.next_year
    to = from.next_month unless month.blank?
    to = from + 1.day unless day.blank?
    to = to - 1 # pull off 1 second so we don't overlap onto the next day
    between(from,to)
  }

  def self.sample
    new(
      :title => 'A Sample Newsitem',
      :description => 'Big News! read more in the body',
      :body => 'More big news. But you already know everything from the description',
      :published_at => Time.now.yesterday
    )
  end

end