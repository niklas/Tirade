class Part < ActiveRecord::Base
  class TemplateNotFound < Exception; end
  class TemplateError < Exception; end
  acts_as_renderer

  attr_accessor :html
  attr_accessor :template

  def render_with_content(content, assigns={})
    return '' if content.nil?
    render(options_with_object(content).merge(assigns).stringify_keys)
  end

  def render(assigns={})
    begin
      self.template = Liquid::Template.parse(liquid)
      self.html = self.template.render(assigns)
    rescue Liquid::SyntaxError => e # FIXME does not work yet, we want to escape the error
      raise TemplateError, %Q[could not compile liquid template '#{filename_with_extention}': #{e.message.h}] 
    end
  end

  def render_with_fake_content(assigns={})
    render_with_content(fake_content, assigns)
  end

  def options_with_object(obj)
    options.to_hash_with_defaults.merge({
      filename.to_sym => obj
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
                  File.read(active_liquid_path)
                else
                  '' # verschwindibus!
                end
  end

  # Sets the new Liquid markup code. Will be written to the theme path after_save
  def liquid=(new_liquid)
    @liquid = new_liquid
  end
  alias_method :code, :liquid
  alias_method :code=, :liquid=


  # The path to the file containing liquid markup. 
  # If it exists in the current theme, this path is preferred
  def active_liquid_path
    template_finder.pick_template(partial_name, extention)
  end
  alias_method :active_path, :active_liquid_path

  def template_finder
    active_controller.instance_variable_get('@template').finder
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
        self.render_with_fake_content
        if t = self.template
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
      self.errors.add(:liquid, '<pre><b>Liquid Error:</b>' + e.message.h + '</pre>')
    end

    unless html.blank?
      parser = XML::Parser.new
      parser.string = "<div>#{html}</div>"
      msgs = []
      XML::Parser.register_error_handler lambda { |msg| msgs << msg }
      begin
        parser.parse
      rescue Exception => e
        self.errors.add(:html, '<pre>' + msgs.collect{|c| c.h }.join + '</pre>')
      end
    else
      # TODO warning when :html is blank?
      #self.errors.add(:html, "no HTML found")
    end
  end

end
