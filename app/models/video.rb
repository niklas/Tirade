# == Schema Information
# Schema version: 20090809211822
#
# Table name: videos
#
#  id          :integer         primary key
#  title       :string(255)     
#  artist_id   :integer         
#  artist_name :string(255)     
#  image_url   :string(255)     
#  created_at  :datetime        
#  updated_at  :datetime        
#  url         :string(255)     
#

require 'uri'
require 'net/http'
require 'xmlsimple'
class Video < ActiveRecord::Base
  attr_accessible :id, :title, :artist_name, :url, :image_url

  validates_uniqueness_of :id

  has_fulltext_search :title, :artist_name, :image_url
  acts_as_content :liquid => [:title, :artist_name, :image_url]

  def self.new_from_xml(xml)
    @document = XmlSimple.xml_in(xml,{ 'Cache' => 'mem_share', 'ForceArray' => false})
    @document['video'].collect do |hsh|
      n = new(
        :title => hsh['title'],
        :artist_name => hsh['artist'],
        :url => hsh['videourl'].match(/^(.*vid=\d+)/).andand[1],
        :image_url => hsh['image']
      )
      n.id = hsh['videoId']
      n
    end
  end

  def self.sync(url_str)
    url = URI.parse url_str
    xml = Net::HTTP.get url
    create_from_xml_unless_exist(xml)
  end

  def self.create_from_xml_unless_exist(xml)
    created = []
    new_from_xml(xml).each do |video|
      created << video if video.valid? && video.save
    end
    created
  end

  def full_url
    APP_CONFIG['video_base_url'] + self.url
  end
  
  def self.sample
    new(
        :title => "Sample Video",
        :artist_name => 'Henry Sample',
        :url => 'http://example.com/no_video',
        :image_url => 'http://example.com/no_image.jpg'
       )
  end
end
