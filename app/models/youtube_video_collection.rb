class YoutubeVideoCollection < Content
  def videos
    YoutubeVideo.all
  end
  alias :items :videos
end
