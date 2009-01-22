# == Schema Information
# Schema version: 20081120155111
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
#  defined_options :text            
#

# A Part is a representation of a rails partial
#
# It has a partial file attached to it and will be rendered in a Grid, using a Content.
# It can take options to modify its apperance, which are passed as :locals (this should be overridable from Rendering)

class Part < ActiveRecord::Base
  acts_as_renderer
  concerned_with :syncing, :content, :code, :liquid, :theme, :configuration, :plugin
  validates_presence_of :name
  validates_uniqueness_of :name
  belongs_to :subpart, :class_name => 'Part', :foreign_key => 'subpart_id'
  acts_as_custom_configurable
  serialize :preferred_types, Array

  attr_accessible :name, :options, :options_as_yaml, :preferred_types, :liquid, :use_theme, :define_options, :defined_options
  liquid_methods :name, :liquid

  PartsDir = File.join('parts','stock')
  BasePath = File.join(RAILS_ROOT,'app','views',PartsDir)
  BaseGlob = File.join(BasePath, '*.html.liquid')
  ThemesGlob = File.join(RAILS_ROOT, 'themes', '*', 'views', PartsDir, '*.html.liquid')
  PluginsGlob = File.join(RAILS_ROOT, 'vendor', 'plugins', '*', 'app', 'views', PartsDir, '*.html.liquid')

  SaveLevel = 1

  # FIXME why doesn't has_finder work here?
  #has_finder :for_content, lambda {|cont|
  #  {:conditions => ['1=1']}
  #}

  has_fulltext_search :name, :filename
  def self.for_content(cont)
    find(:all, :order => 'name')
  end

  after_save :save_configuration_if_needed!
  after_save :save_code_if_needed!
  after_destroy :delete_configuration
  after_destroy :delete_code


  def after_initialize
    self.options ||= {}
  rescue ActiveRecord::SerializationTypeMismatch
    self.options = {}
  end

  def label
    name
  end

  def fullname
    in_theme? ? "#{name} (#{current_theme})" : name
  end

  def title
    if !active_plugin.blank?
      "#{name} in '#{active_plugin}' plugin"
    elsif !active_theme.blank?
      "#{name} in '#{active_theme}' theme"
    elsif in_theme?
      "#{name} in '#{current_theme}' theme"
    else
      name
    end
  end

  def filename
    self[:filename] ||= filename_by_name
  end

  def name=(new_name)
    self[:name] = new_name
    self[:filename] = filename_by_name
    new_name
  end

  def partial_name
    File.join(PartsDir,filename || '')
  end

  def filename_with_extention
    filename.andand.ends_with?(".#{extention}") ? filename : [filename, extention].join('.')
  end

  private
  def filename_by_name
    name.andand.domify
  end

end
