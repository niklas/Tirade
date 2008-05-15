# == Schema Information
# Schema version: 17
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
  belongs_to :subpart, :class_name => 'Part', :foreign_key => 'subpart_id'
  serialize :options, Hash
  serialize :preferred_types, Array

  attr_accessible :name, :filename, :options, :options_as_yaml, :preferred_types, :rhtml

  PartsDir = 'stock'
  BasePath = File.join(RAILS_ROOT,'app','views','parts',PartsDir)
  BaseGlob = File.join(BasePath, '_*.html.erb')
  ThemesGlob = File.join(RAILS_ROOT, 'themes', '*', 'views', 'parts', PartsDir, '_*.html.erb')

  SaveLevel = 3

  # FIXME why doesn't has_finder work here?
  #has_finder :for_content, lambda {|cont|
  #  {:conditions => ['1=1']}
  #}
  def self.for_content(cont)
    find(:all)
  end

  def self.recognize_new_files
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
    @use_theme = false
    self.options ||= {}
  rescue ActiveRecord::SerializationTypeMismatch
    self.options = {}
  end

  def options_as_yaml
    self.options.to_yaml
  end

  def options_as_yaml=(new_yaml_options)
    write_attribute :options, object_from_yaml(new_yaml_options)
  end

  # FIXME dynamicx, reusable!
  def self.valid_content_types
    Rendering.valid_content_types
  end

  def preferred_types
    read_attribute(:preferred_types) || []
  end

  def rhtml(reload=false)
    @rhtml = nil if reload
    @rhtml ||= File.read(fullpath)
  rescue
    ''
  end

  def rhtml=(new_rhtml)
    @rhtml = new_rhtml
  end

  # Returns the path to the existing part file, theme is tried first
  def existing_fullpath(theme=nil)
    paths = []
    paths << fullpath_for_theme(theme) if (theme || use_theme)
    paths << default_fullpath

    paths.find {|p| File.exists?(p)} || default_fullpath
  end

  def fullpath
    if use_theme
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
    render_to_string(:inline => self.rhtml, :locals => assigns.merge(options_with_object(content)))
  end

  def render(assigns={})
    render_with_content(fake_content)
  end

  def options_with_object(obj)
    options.merge({
      filename.to_sym => obj
    })
  end

  # Theme stuff
  attr_accessor :use_theme

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
end
