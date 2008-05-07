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

  SaveLevel = 3

  # FIXME why doesn't has_finder work here?
  #has_finder :for_content, lambda {|cont|
  #  {:conditions => ['1=1']}
  #}
  def self.for_content(cont)
    find(:all)
  end

  def self.recognize_new_files
    pattern = File.join(BasePath,'*.html.erb')
    created = []
    Dir.glob(pattern).each do |filename|
      filename_without_extention = File.basename(filename).sub(%r~\.html\.erb$~,'').sub(/^_/,'')
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
      errors.add(:rhtml, 'is not renderable: ' + e.message)
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

  def options_as_yaml
    self.options.to_yaml
  end

  def options_as_yaml=(new_yaml_options)
    write_attribute :options, object_from_yaml(new_yaml_options)
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

  private
  def save_rhtml!
    return if rhtml.blank?
    File.open(fullpath,'w') do |file|
      file.puts rhtml.gsub(/\r/,'')
    end
  end

  def name_by_filename
    filename.andand.titleize
  end

  def fake_content
    (preferred_types.andand.first || Document).sample
  end
end
