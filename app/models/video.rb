# == Schema Information
# Schema version: 16
#
# Table name: videos
#
#  id          :integer         primary key
#  title       :string(255)     
#  artist_id   :integer         
#  artist_name :string(255)     
#  urls        :text            
#  image_url   :string(255)     
#  created_at  :datetime        
#  updated_at  :datetime        
#

require 'uri'
require 'net/http'
require 'xmlsimple'
class Video < ActiveRecord::Base
  attr_accessible :id, :title, :artist_name, :urls, :image_url
  serialize :urls, Hash

  validates_uniqueness_of :id


  def self.new_from_xml(xml)
    @document = XmlSimple.xml_in(xml,{ 'Cache' => 'mem_share', 'ForceArray' => false})
    @document['video'].collect do |hsh|
      n = new(
        :title => hsh['title'],
        :artist_name => hsh['artist'],
        :urls => {
          :high => hsh['videourl'], 
          :low => hsh['videourllo']
        },
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
end
