class Part < ActiveRecord::Base
  attr_accessor :current_plugin

  def remove_plugin!(plugin)
    File.delete plugin_path(plugin) if File.file?( plugin_path(plugin) )
    File.delete plugin_configuration_path(plugin) if File.file?( plugin_configuration_path(plugin) )
    return true
  end

  def plugin_path(plugin)
    File.join(RAILS_ROOT,'vendor','plugins',plugin,'app','views', PartsDir, filename_with_extention)
  end

  def plugin_configuration_path(plugin)
    configuration_path_of plugin_path(plugin)
  end
end

