# == Schema Information
# Schema version: 20090412210854
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

class Folder < Content
  acts_as_content :liquid => [:title, :description, :slug]
  def self.root
    find_by_parent_id nil
  end
  def self.sample
    new(
      :title => 'Example Folder',
      :description => "You won't find anything in this Folder"
    )
  end
  def icon_name
    'folder'
  end
end
