class YoutubeVideoCollection < Content
  def videos
    YoutubeVideo.find(:all)
  end
  alias :items :videos

  def self.sample
    new(:title => 'Sample Youtube')
  end
end
