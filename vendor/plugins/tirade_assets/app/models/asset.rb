class Asset < ActiveRecord::Base
  acts_as_content :liquid => [:title, :description, :file_url]
  attr_accessible :title, :description, :file
  markup :description

  has_attached_file :file, 
    :path => ":rails_root/public/upload/:attachment/:id/:style/:basename.:extension",
    :url => "/upload/:attachment/:id/:style/:basename.:extension"
  validates_attachment_presence :file

  def file_url
    file.url
  end

  def self.sample
    new(
              :title => 'An Asset',
              :description => 'Description of Asset' 
          )
  end
end

