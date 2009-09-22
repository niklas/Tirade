class Part < ActiveRecord::Base
  class TemplateNotFound < Exception; end
  class TemplateError < Exception; end

  attr_accessor :html

  def render_with_content(content, assigns={}, context=nil)
    return '' if content.nil?
    options = options_with_object(content).merge(assigns || {})
    render(options,context)
  end

  def render(assigns={},context=nil)
    #return %Q~rwc: <pre>#{assigns.to_yaml}</pre>~
    begin
      self.html = compiled_liquid.render(assigns.stringify_keys, context)
    rescue Liquid::SyntaxError => e # FIXME does not work yet, we want to escape the error
      raise TemplateError, %Q[could not compile liquid template '#{filename_with_extention}': #{e.message.h}] 
    end
  end

  def compiled_liquid
    @compiled_liquid ||= Liquid::Template.parse(liquid)
  end

  def render_with_fake_content(assigns={})
    render_with_content(fake_content, assigns)
  end

  def options_with_object(obj)
    options.to_hash_with_defaults.merge({
      filename.to_sym => obj,
      :object => obj
    })
  end

  def self.extention
    'html.liquid'
  end
  def extention
    self.class.extention
  end
  # The Liquid markup saved in the #active_liquid_path
  def liquid(reload=false)
    @liquid = nil if reload
    @liquid ||= if liquid_loadable?
                  load_liquid_from active_liquid_path
                else
                  '<div class="warning">no liquid code found</div>' # verschwindibus!
                end
  end

  # Sets the new Liquid markup code. Will be written to the theme path after_save
  def liquid=(new_liquid)
    self.updated_at = Time.now if liquid != new_liquid
    @liquid = new_liquid
  end
  alias_method :code, :liquid
  alias_method :code=, :liquid=

  def load_liquid_from(path)
    File.read(path)
  end

  # The path to the file containing liquid markup. 
  # If it exists in the current theme, this path is preferred
  def active_liquid_path
    if !current_plugin.blank? && File.file?( plugin_path(current_plugin) )
      plugin_path(current_plugin)
    else
      liquid_paths.find do |path|
        File.file? path
      end
    end
  end
  alias_method :active_path, :active_liquid_path

  # Avaiable drectories, both existing and nonexisting
  def stock_dirs
    [
      File.join(RAILS_ROOT, 'themes', current_theme, 'views', PartsDir),
      Tirade::Plugins.all_paths.map {|path| File.join(path,'app','views', PartsDir)},
      BasePath
    ].flatten
  end

  def alternatives
    existing_liquid_paths.map do |path|
      if path =~ %r~themes/(\w+)/views~
        {:place => 'theme', :name => $1}
      elsif path =~ %r~vendor/plugins/(\w+)/app/views~
        {:place => 'plugin', :name => $1}
      elsif path =~ %r~app/views~
        {:place => 'buildin', :name => 'default'}
      end
    end
  end

  def existing_liquid_paths
    liquid_paths.select do |path|
      File.file? path
    end
  end

  def liquid_paths
    stock_dirs.map do |dir|
      File.join(dir,filename_with_extention)
    end
  end

  def liquid_loadable?
    active_liquid_path
  end

  # The full path to the liquid code in the Stock view dir
  def liquid_stock_path
    File.join(BasePath,filename_with_extention)
  end
  alias_method :stock_path, :liquid_stock_path

  # The full path to the liquid code in the current theme
  def liquid_theme_path(theme=nil)
    theme ||= current_theme
    File.join(RAILS_ROOT,'themes',theme,'views', PartsDir, filename_with_extention)
  end
  alias_method :theme_path, :liquid_theme_path

  validate :must_be_renderable, :unless => Proc.new { |part| part.filename.blank? }
  def must_be_renderable
    begin
      if @liquid || liquid_loadable?
        if t = compiled_liquid
          t.errors.each do |e|
            self.errors.add(:liquid, '<pre>' + e.clean_message.h + e.clean_backtrace.first.h + '</pre>')
          end
        end
      else
        # TODO warning when :liquid is not loadable?
        #self.errors.add(:liquid, "No Liquid markup code found")
      end
    rescue TemplateError => e
      self.errors.add(:liquid, '<pre><b>Liquid Error:</b>' + e.message.h + '</pre>')
    rescue TemplateNotFound => e
      self.errors.add(:liquid, '<pre><b>Liquid Template not found:</b>' + e.message.h + '</pre>')
    rescue UnsupportedContentType => e
      self.errors.add(:content_type, e.message)
    end

    must_have_valid_html
  end

  def must_have_valid_html
    unless html.blank?
      parser = XML::Parser.string "<div>#{html}</div>"
      msgs = []
      XML::Error.set_handler { |error| msgs << error.to_s }
      begin
        parser.parse
      rescue Exception => e
        self.errors.add(:html, '<pre>' + msgs.collect{|c| c.to_s.h }.join + '</pre>')
      ensure
        XML::Error.reset_handler
      end

    else
      # TODO warning when :html is blank?
      #self.errors.add(:html, "no HTML found")
    end
  end

end
