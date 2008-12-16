class Part < ActiveRecord::Base
  acts_as_renderer

  attr_accessor :html
  attr_accessor :template

  def render_with_content(content, assigns={})
    return '' if content.nil?
    render(options_with_object(content).merge(assigns).stringify_keys)
  end

  def render(assigns={})
    if liquid.blank?
      return %Q[<div class="warning"> could not find liquid template '#{filename_with_extention}'</div>] 
    end
    begin
      self.template = Liquid::Template.parse(liquid)
      self.html = self.template.render(assigns)
    rescue Exception => e # FIXME does not work yet, we want to escape the error
      self.html << e.h
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
    '.html.liquid'
  end
  def extention
    self.class.extention
  end
  # The Liquid markup saved in the #active_liquid_path
  def liquid(reload=false)
    @liquid = nil if reload
    @liquid ||= File.read(active_liquid_path)
  rescue Exception => e
    ''
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
    if in_theme?
      liquid_theme_path
    else
      liquid_stock_path
    end
  end
  alias_method :active_path, :active_liquid_path

  # The full path to the liquid code in the Stock view dir
  def liquid_stock_path
    File.join(BasePath,filename_with_extention)
  end
  alias_method :stock_path, :liquid_stock_path

  # The full path to the liquid code in the current theme
  def liquid_theme_path(theme=nil)
    theme ||= current_theme
    File.join(RAILS_ROOT,'themes',theme,'views', 'parts', PartsDir, filename_with_extention)
  end
  alias_method :theme_path, :liquid_theme_path


  validates_each :liquid do |part, attr, liquid|
    unless liquid.blank?
      begin
        part.render_with_fake_content
      rescue Liquid::SyntaxError => e
        part.errors.add(:liquid, '<pre>' + e.message.h + '</pre>')
      end
      if t = part.template
        t.errors.each do |e|
          part.errors.add(:liquid, '<pre>' + e.clean_message.h + e.clean_backtrace.first.h + '</pre>')
        end
      end
    else
      #part.errors.add(:liquid, "No Liquid markup code found")
    end
  end
  validates_each :html do |part, attr, html|
    unless html.blank?
      parser = XML::Parser.new
      parser.string = "<div>#{html}</div>"
      msgs = []
      XML::Parser.register_error_handler lambda { |msg| msgs << msg }
      begin
        parser.parse
      rescue Exception => e
        part.errors.add(:html, '<pre>' + msgs.collect{|c| c.h }.join + '</pre>')
      end
    else
      #part.errors.add(:html, "no HTML found")
    end
  end

end
