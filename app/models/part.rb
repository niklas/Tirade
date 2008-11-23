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
  concerned_with :syncing, :rendering, :content, :rhtml
  validates_presence_of :name
  validates_uniqueness_of :name
  belongs_to :subpart, :class_name => 'Part', :foreign_key => 'subpart_id'
  acts_as_custom_configurable
  serialize :preferred_types, Array

  attr_accessible :name, :filename, :options, :options_as_yaml, :preferred_types, :rhtml, :use_theme, :define_options, :defined_options

  PartsDir = 'stock'
  BasePath = File.join(RAILS_ROOT,'app','views','parts',PartsDir)
  BaseGlob = File.join(BasePath, '_*.html.erb')
  ThemesGlob = File.join(RAILS_ROOT, 'themes', '*', 'views', 'parts', PartsDir, '_*.html.erb')

  SaveLevel = 1

  # FIXME why doesn't has_finder work here?
  #has_finder :for_content, lambda {|cont|
  #  {:conditions => ['1=1']}
  #}

  has_fulltext_search :name, :filename
  def self.for_content(cont)
    find(:all, :order => 'name')
  end

  def before_validation_on_create
    self.name ||= name_by_filename
  end

  def after_find
    @use_theme = in_theme?
    #sync_attributes
  end

  def after_initialize
    self.options ||= {}
  rescue ActiveRecord::SerializationTypeMismatch
    self.options = {}
  end

  def options_as_yaml
    self.options.to_yaml
  end

  def options_as_yaml=(new_yaml_options)
    self.options = object_from_yaml(new_yaml_options)
  end

  def label
    name
  end

  # Theme stuff
  def use_theme=(useit)
    @use_theme = ![false, "false", "f", 0, "0", nil, ""].include?(useit)
  end
  def use_theme
    @use_theme
  end
  def use_theme?
    use_theme
  end

  # Does a counterpart of this file exists in the given theme, defaults to the current theme of the +active_controller+
  def in_theme?(theme_name=nil)
    File.exists? fullpath_for_theme(theme_name)
  end

  def current_theme
    active_controller.andand.current_theme
  end

  def fullname
    in_theme? ? "#{name} (#{current_theme})" : name
  end

  def make_themable!(theme_name=nil)
    theme_name ||= current_theme
    self.use_theme = true
    if in_theme?(theme_name)
      return true
    else
      save_rhtml_in_theme!
    end
  end

  def make_unthemable!(theme_name=nil)
    theme_name ||= current_theme
    if in_theme?(theme_name)
      File.delete fullpath_for_theme(theme_name)
    end
    self.use_theme = false
  end

  def name_by_filename
    filename.andand.titleize
  end

end
