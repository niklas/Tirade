class Asset < ActiveRecord::Base
  acts_as_content :liquid => [:title, :description]
  attr_accessible :title, :description
  markup :description

  has_attached_file :file
  validates_attachment_presence

  def self.sample
    new(
              :title => 'An Asset',
              :description => 'Description of Asset' 
          )
  end
end

