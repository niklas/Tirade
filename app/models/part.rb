# == Schema Information
# Schema version: 3
#
# Table name: parts
#
#  id              :integer         not null, primary key
#  name            :string(255)     
#  filename        :string(255)     
#  options         :text            
#  preferred_types :text            
#  subpart_id      :integer         
#  created_at      :datetime        
#  updated_at      :datetime        
#

# A Part is a representation of a rails partial
#
# It has a partial file attached to it and will be rendered in a Grid, using a Content.
# It can take options to modify its apperance, which are passed as :locals
class Part < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :filename
  validates_uniqueness_of :filename
  validates_format_of :filename, :with => /\A\S+\Z/
  belongs_to :subpart, :class_name => 'Part', :foreign_key => 'subpart_id'
  serialize :options, Hash
  serialize :preferred_types, Array

  BasePath = File.join(RAILS_ROOT,'app','views','parts','stock')

  def after_save
    save_rhtml!
  end

  def rhtml
     @rhtml ||= File.read(fullpath)
  rescue
    ''
  end

  def rhtml=(new_rhtml)
    @rhtml = new_rhtml
  end

  def fullpath
    File.join(BasePath,filename_with_extention)
  end

  def filename_with_extention
    filename.match(/\.html\.erb$/) ? filename : (filename + '.html.erb')
  end

  private
  def save_rhtml!
    File.open(fullpath,'w') do |file|
      file.puts new_rhtml
    end
  end
end
