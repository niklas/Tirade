class Part < ActiveRecord::Base
  BlacklistesFileNames = %w(
    exit
    filename
    name
  )
  after_save :save_rhtml!
  after_destroy :delete_rhtml

  validates_presence_of :filename
  validates_uniqueness_of :filename
  validates_format_of :filename, :with => /\A[\w_]+\Z/
  validates_exclusion_of :filename, :in => BlacklistesFileNames
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

  def needs_sync?
    return true unless File.exists?(fullpath)
    updated_at < File.mtime(fullpath)
  end

  def fullpath
    if use_theme?
      fullpath_for_theme
    else
      default_fullpath
    end
  end

  def existing_fullpath(theme=nil)
    if in_theme?(theme)
      fullpath_for_theme(theme)
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

  def delete_rhtml
    File.delete fullpath if File.exists?(fullpath)
  rescue
  end
end
