namespace :tirade do
  namespace :sync do
    desc "Sync Videos from YouTube"
    task :youtube => [:environment] do
      YoutubeVideo.sync('http://youtube.com/rss/global/top_rated_today.rss')
    end
  end
end
