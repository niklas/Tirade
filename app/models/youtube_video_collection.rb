class YoutubeVideoCollection < Content
  def videos
    YoutubeVideo.all
  end
  alias :items :videos

  def self.sample
    new(:title => 'Sample Youtube')
  end
end
