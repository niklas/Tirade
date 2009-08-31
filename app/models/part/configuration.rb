class Part < ActiveRecord::Base
  ConfigurationFields = [:preferred_types, :defined_options, :description].map(&:to_s) unless defined?(ConfigurationFields)

  def options_as_yaml
    self.options.to_yaml
  end

  def options_as_yaml=(new_yaml_options)
    self.options = object_from_yaml(new_yaml_options)
  end

  def configuration=(new_configuration)
    self.attributes = new_configuration.stringify_keys.slice(*ConfigurationFields)
  end

  def configuration
    self.attributes.slice(*ConfigurationFields).symbolize_keys
  end

  def configuration_paths
    stock_dirs.map do |dir|
      configuration_path_of File.join(dir,filename_with_extention)
    end
  end

  # returns the path to the active yml file
  def active_configuration_path
    configuration_paths.find do |path|
      File.file? path
    end || theme_configuration_path
  end

  def stock_configuration_path
    configuration_path_of stock_path
  end

  def theme_configuration_path(theme=nil)
    configuration_path_of theme_path(theme)
  end

  # returns the path for the configuration next to the given path
  def configuration_path_of(original_path)
    original_path.sub(/\.#{extention}$/,'.yml')
  end

  # Saves the needed attributes to a .yml file or reads them in from there
  def sync_configuration!
    load_configuration_if_needed! and save
    save_configuration_if_needed!
  end


  def load_configuration_from(yaml_path)
    yaml_path = configuration_path_of yaml_path
    yaml = YAML.load_file(yaml_path)
    yaml ? yaml.symbolize_keys : {}
  rescue Errno::ENOENT
    nil
  end

  def write_configuration_to(yaml_path)
    yaml_path = configuration_path_of yaml_path
    FileUtils.mkdir_p File.dirname(yaml_path)
    File.open(yaml_path, 'w') do |f|
      f.puts self.configuration.to_yaml
    end
  end

  private


  def needs_to_write_configuration?
    acp = active_configuration_path
    if File.file?(acp)
      !configuration.blank? && configuration != load_configuration_from(acp)
    else
      true
    end
  end

  def save_configuration_if_needed!
    write_configuration_to(theme_configuration_path) if needs_to_write_configuration?
  end

  def needs_to_load_configuration_from?(yp)
    File.exists?(yp) && ( new_record? || File.mtime(yp) > (updated_at) )
  end

  def load_configuration_if_needed!
    if needs_to_load_configuration_from?(active_configuration_path)
      conf = load_configuration_from active_configuration_path
      unless conf.blank?
        self.configuration = conf
      end
    end
  end

  def delete_configuration
    configuration_paths.each do |path|
      File.delete(path) if File.file?(path)
    end
    true
  end

end
