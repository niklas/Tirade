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
# It can take options to modify its apperance, which are passed as :locals (this should be overridable from Rendering)
class Part < ActiveRecord::Base
  BlacklistesFileNames = %w(
    exit
  )
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :filename
  validates_uniqueness_of :filename
  validates_format_of :filename, :with => /\A[\w_]+\Z/
  validates_exclusion_of :filename, :in => BlacklistesFileNames
  belongs_to :subpart, :class_name => 'Part', :foreign_key => 'subpart_id'
  serialize :options, Hash
  serialize :preferred_types, Array

  attr_accessible :name, :filename, :options, :preferred_types, :rhtml

  PartsDir = 'stock'
  BasePath = File.join(RAILS_ROOT,'app','views','parts',PartsDir)

  def self.recognize_new_files
    pattern = File.join(BasePath,'*.html.erb')
    created = []
    Dir.glob(pattern).each do |filename|
      filename_without_extention = File.basename(filename).sub(%r~\.html\.erb$~,'')
      puts filename_without_extention
      unless find_by_filename(filename_without_extention)
        created << create!(:filename => filename_without_extention)
      end
    end
    created
  end

  def before_validation_on_create
    self.name ||= name_by_filename
  end

  def after_save
    save_rhtml!
  end

  def after_destroy
    File.delete fullpath
  rescue
  end

  def options
    read_attribute(:options) || {}
  end

  def preferred_types
    read_attribute(:preferred_types) || []
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

  def partial_name
    File.join(PartsDir,filename)
  end

  def filename_with_extention
    filename.match(/\.html\.erb$/) ? filename : (filename + '.html.erb')
  end

  private
  def save_rhtml!
    return if rhtml.blank?
    File.open(fullpath,'w') do |file|
      file.puts rhtml.gsub(/\r/,'')
    end
  end

  def name_by_filename
    filename.titleize
  end
end
