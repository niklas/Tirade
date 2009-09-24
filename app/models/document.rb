# == Schema Information
# Schema version: 20090809211822
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

# A Document is a simple Text, nothing special for now
class Document < Content
  acts_as_content :liquid => [:title, :description, :body, :slug, :image, :summary, :images, :has_image?],
    :translate => [:title, :description, :body]
end
