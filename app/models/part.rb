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
  BlacklistesFileNames = %w(
    exit
    filename
    name
  )
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :filename
  validates_uniqueness_of :filename
  validates_format_of :filename, :with => /\A[\w_]+\Z/
  validates_exclusion_of :filename, :in => BlacklistesFileNames
  validates_length_of :preferred_types, :minimum => 1, :message => 'are not enough. Please select at least one.'
  belongs_to :subpart, :class_name => 'Part', :foreign_key => 'subpart_id'
  acts_as_custom_configurable
  serialize :preferred_types, Array

  attr_accessible :name, :filename, :options, :options_as_yaml, :preferred_types, :rhtml, :use_theme, :define_options, :defined_options

  PartsDir = 'stock'
  BasePath = File.join(RAILS_ROOT,'app','views','parts',PartsDir)
  BaseGlob = File.join(BasePath, '_*.html.erb')
  ThemesGlob = File.join(RAILS_ROOT, 'themes', '*', 'views', 'parts', PartsDir, '_*.html.erb')

  SaveLevel = 3

  # FIXME why doesn't has_finder work here?
  #has_finder :for_content, lambda {|cont|
  #  {:conditions => ['1=1']}
  #}

  has_fulltext_search :name, :filename
  def self.for_content(cont)
    find(:all, :order => 'name')
  end

  def self.sync_from_filesystem
    created = []
    [BaseGlob, ThemesGlob].each do |pattern|
      Dir.glob(pattern).each do |filename|
        filename_without_extention = File.basename(filename).sub(%r~\.html\.erb$~,'').sub(/^_/,'')
        unless find_by_filename(filename_without_extention)
          created << create!(:filename => filename_without_extention)
        end
      end
    end
    created
  end

  def self.sync!
    find(:all).each do |part|
      part.sync_attributes
    end
    sync_from_filesystem
  end

  def before_validation_on_create
    self.name ||= name_by_filename
    sync_attributes
  end

  def before_validation
    self.preferred_types = ['Document'] if preferred_types.empty?
  end

  def after_save
    save_rhtml!
  end

  def after_destroy
    File.delete fullpath
  rescue
  end

  def validate
    validate_rhtml
  end

  def validate_rhtml
    begin
      if errors.on(:filename)
        errors.add(:rhtml, 'Will check RHTML only if filename is valid')
        return
      end
      @html = self.render
      validate_html
    rescue SecurityError => e
      errors.add(:rhtml, 'does something illegal: ' + e.message)
    rescue Exception => e
      errors.add(:rhtml, "is not renderable: (#{filename})" + ERB::Util::html_escape(e.message))
    end
  end

  def validate_html
    return if @html.blank?
    parser = XML::Parser.new
    parser.string = "<div>#{@html}</div>"
    msgs = []
    XML::Parser.register_error_handler lambda { |msg| msgs << msg }
    begin
      parser.parse
    rescue Exception => e
      errors.add(:rhtml, '<pre>' + msgs.collect{|c| c.gsub('<', '&lt;') }.join + '</pre>')
    end
  end

  def after_initialize
    self.options ||= {}
  rescue ActiveRecord::SerializationTypeMismatch
    self.options = {}
  end

  def after_find
    @use_theme = in_theme?
    #sync_attributes
  end

  def options_as_yaml
    self.options.to_yaml
  end

  def options_as_yaml=(new_yaml_options)
    self.options = object_from_yaml(new_yaml_options)
  end

  # FIXME dynamicx, reusable!
  def self.valid_content_types
    Rendering.valid_content_types
  end

  def preferred_types
    read_attribute(:preferred_types) || []
  end

  def preferred_types_names
    preferred_types.join(', ')
  end

  def label
    name
  end

  def rhtml(reload=false)
    @rhtml = nil if reload
    @rhtml ||= File.read(existing_fullpath)
  rescue Exception => e
    ''
  end

  def rhtml=(new_rhtml)
    @rhtml = new_rhtml
  end

  def existing_fullpath(theme=nil)
    if in_theme?(theme)
      fullpath_for_theme(theme)
    else
      default_fullpath
    end
  end

  def fullpath
    if use_theme?
      fullpath_for_theme
    else
      default_fullpath
    end
  end

  def default_fullpath
    File.join(BasePath,filename_with_extention)
  end

  def fullpath_for_theme(theme=nil)
    theme ||= current_theme
    File.join(RAILS_ROOT,'themes',theme,'views', 'parts', PartsDir, filename_with_extention)
  end

  def absolute_partial_name
    '/' + File.join('parts',PartsDir,filename) + '.html.erb'
  end
  def partial_name
    File.join(PartsDir,filename)
  end

  def filename_with_extention
    real_filename.match(/\.html\.erb$/) ? real_filename : (real_filename + '.html.erb')
  end

  def real_filename
    '_' + filename
  end

  def real_filename=(real)
    self.filename = real.gsub(/^_*/,'')
  end

  def render_with_content(content, assigns={})
    return '' if content.nil?
    render_to_string(:inline => self.rhtml, :locals => options_with_object(content).merge(assigns))
  end

  def render(assigns={})
    render_with_content(fake_content, assigns)
  end

  def options_with_object(obj)
    options.to_hash_with_defaults.merge({
      filename.to_sym => obj
    })
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

  # Saves the needed attributes to a .yml file or reads them in from there
  def sync_attributes
    yaml_path = existing_yml_path rescue nil
    unless yaml_path.blank?
      if File.exist?(yaml_path) and File.mtime(yaml_path) > (updated_at || Time.now.yesterday)
        load_attributes_from_yml_file(yaml_path)
        save! unless new_record?
        # FIXME is there another wy to prevent conf saving in tests?
      elsif !new_record? and RAILS_ENV != 'test'
        write_attributes_to_yml_file(yaml_path)
      end
    end
  end

  private
  def save_rhtml!
    return if rhtml.blank?
    save_rhtml_to! fullpath
  end

  def save_rhtml_in_theme!
    return if rhtml.blank?
    save_rhtml_to! fullpath_for_theme
  end

  def save_rhtml_to!(path)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path,'w') do |file|
      file.puts rhtml.gsub(/\r/,'')
    end
  end

  def name_by_filename
    filename.andand.titleize
  end

  def fake_content
    (preferred_types.andand.first || "Document").constantize.sample
  end

  # returns the path to a yml file where the rhtml exists
  def existing_yml_path
    existing_fullpath.sub(/.html.erb$/,'.yml')
  end

  def write_attributes_to_yml_file(yaml_path)
    File.open(yaml_path, 'w') do |f|
      at = {
        :preferred_types => preferred_types,
        :defined_options => defined_options
      }
      f.puts at.to_yaml
    end
  end

  def load_attributes_from_yml_file(yaml_path)
    atts = YAML.load_file(yaml_path)
    unless atts.blank?
      self.attributes = atts
    end
  end
end
