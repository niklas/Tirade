class Part < ActiveRecord::Base
  def options_as_yaml
    self.options.to_yaml
  end

  def options_as_yaml=(new_yaml_options)
    self.options = object_from_yaml(new_yaml_options)
  end

  # returns the path to a yml file where the rhtml exists
  def active_configuration_path
    configuration_path(active_path || theme_path)
  end

  def stock_configuration_path
    configuration_path stock_path
  end

  def theme_configuration_path
    configuration_path theme_path
  end

  # returns the path for the configuration next to the given path
  def configuration_path(original_path)
    original_path.sub(/\.#{extention}$/,'.yml')
  end

  # Saves the needed attributes to a .yml file or reads them in from there
  def sync_configuration!
    load_configuration_if_needed! and save
    save_configuration_if_needed!
  end


  def load_configuration_from(yaml_path)
    yaml_path = configuration_path yaml_path
    atts = YAML.load_file(yaml_path)
    unless atts.blank?
      self.attributes = atts
    end
  rescue Errno::ENOENT
    nil
  end

  def write_configuration_to(yaml_path)
    yaml_path = configuration_path yaml_path
    FileUtils.mkdir_p File.dirname(yaml_path)
    File.open(yaml_path, 'w') do |f|
      at = {
        :preferred_types => preferred_types,
        :defined_options => defined_options
      }
      f.puts at.to_yaml
    end
  end

  private


  def needs_to_write_configuration?
    yp = active_configuration_path
    !File.exists?(yp) or
    File.mtime(yp) < (updated_at || Time.now.yesterday)
  end

  def save_configuration_if_needed!
    write_configuration_to(active_configuration_path) if needs_to_write_configuration?
  end

  def needs_to_load_configuration_from?(yp)
    File.exists?(yp) && ( new_record? || File.mtime(yp) > (updated_at) )
  end

  def load_configuration_if_needed!
    if needs_to_load_configuration_from?(active_configuration_path)
      load_configuration_from active_configuration_path
    end
  end

  def delete_configuration
    File.delete(stock_configuration_path) if File.exists?(stock_configuration_path)
    File.delete(theme_configuration_path) if File.exists?(theme_configuration_path)
    true
  end

end
