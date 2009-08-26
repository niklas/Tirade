module Tirade::ThemedCssDryer
  def self.included(controller)
    controller.class_eval do
      alias_method_chain :stylesheets, :dry
    end
  end
  def render_dried_stylesheet(file, theme)
    file_name = file.sub(/\.css/,'.ncss')
    file_path = "#{Theme.path_to_theme(params[:theme])}/stylesheets/#{file_name}"
    if file.split(%r{[\\/]}).include?("..") || !File.exists?(file_path) || file.blank?
      return
    else
      append_view_path("#{Theme.path_to_theme(params[:theme])}/stylesheets")
      render :template => file_name, :content_type => 'text/css'
    end
  end

  def stylesheets_with_dry
    logger.debug("ThemedCssDryeThemedCssDryerr")
    render_dried_stylesheet(joined_filename, params[:theme]) || stylesheets_without_dry
  end

end

::ThemeController.send :include, Tirade::ThemedCssDryer
