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
  concerned_with :syncing, :content, :code, :liquid, :theme, :configuration
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
    load_yml_if_needed!
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

  def fullname
    in_theme? ? "#{name} (#{current_theme})" : name
  end

  def filename
    self[:filename] ||= filename_by_name
  end

  def name=(new_name)
    self[:name] = new_name
    self[:filename] = filename_by_name
    new_name
  end

  private
  def filename_by_name
    name.andand.domify
  end

end
