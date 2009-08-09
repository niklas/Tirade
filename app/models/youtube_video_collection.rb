# == Schema Information
# Schema version: 20090809144154
#
# Table name: contents
#
#  id           :integer         not null, primary key
#  title        :string(255)     
#  description  :text            
#  body         :text            
#  type         :string(255)     
#  state        :string(255)     
#  owner_id     :integer         
#  published_at :datetime        
#  position     :integer         
#  parent_id    :integer         
#  lft          :integer         
#  rgt          :integer         
#  created_at   :datetime        
#  updated_at   :datetime        
#  slug         :string(255)     default("")
#

class YoutubeVideoCollection < Content
  def videos
    YoutubeVideo.find(:all)
  end
  alias :items :videos

  def self.sample
    new(:title => 'Sample Youtube')
  end
end
