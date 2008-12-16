class Part < ActiveRecord::Base

  after_save :save_yml_if_needed!
  after_destroy :delete_yml


  private
  # returns the path to a yml file where the rhtml exists
  def active_yml_path
    active_path.sub(extention,'.yml')
  end

  def yml_stock_path
    stock_path.sub(extention, '.yml')
  end

  def yml_theme_path
    theme_path.sub(extention, '.yml')
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

  def needs_to_write_yml?
    yp = active_yml_path
    !File.exists?(yp) or
    File.mtime(yp) < (updated_at || Time.now.yesterday)
  end

  def save_yml_if_needed!
    write_attributes_to_yml_file(active_yml_path) if needs_to_write_yml?
  end

  def needs_to_load_yml_from?(yp)
    File.exists?(yp) and ( new_record? || File.mtime(yp) > (updated_at) )
  end

  def load_yml_if_needed!
    if in_theme? && needs_to_load_yml_from?(yml_theme_path)
      load_attributes_from_yml_file(yml_theme_path)
    elsif needs_to_load_yml_from?(yml_stock_path)
      load_attributes_from_yml_file(yml_stock_path)
    end
  end

  def delete_yml
    File.delete(yml_stock_path) if File.exists?(yml_stock_path)
    File.delete(yml_theme_path) if File.exists?(yml_theme_path)
    true
  end

end
