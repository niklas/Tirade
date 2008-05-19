class YoutubeVideo < Video
  def self.new_from_rss(rss)
    @document = XmlSimple.xml_in(rss,{ 'Cache' => 'mem_share', 'ForceArray' => false})
    @document['channel']['item'].collect do |hsh|
      n = new(
        :title => hsh['title'].first,
        :artist_name => hsh['credit'],
        :url => hsh['guid']['content'],
        :image_url => hsh['thumbnail']['url']
      )
      n.id = hsh['guid']['content'].match(%r[http://youtube.com/\?v=(.*)$]).andand[1]
      n
    end
  end
end
