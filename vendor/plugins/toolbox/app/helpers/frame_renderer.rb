class FrameRenderer
  attr_reader :template, :options
  def initialize(template, options={})
    @template = template
    @options = options
    add_links
  end

  def self.for(thingy, partial, template, opts={})
    if thingy.respond_to?(:each)
      CollectionFrameRenderer.new(thingy, partial, template, opts)
    else
      RecordFrameRenderer.new(thingy, partial, template, opts)
    end
  end

  def partial
    'frame'
  end

  def links
    []
  end

  def add_links
    links.each do |link|
      template.content_for :linkbar, link
    end
  end

  def html
    template.content_tag(:div, inner, html_options)
  end

  def inner
    template.render render_options
  end

  def html_options
    css.each do |clss|
      template.add_class_to_html_options options, clss
    end
    options[:data] = meta.to_json
    options
  end

  def css
    ['frame']
  end

  def action
    (options[:action] || controller.action_name).to_s
  end

  def title
    "Frame"
  end

  def meta
    {
      :href => request.url, 
      :action => action, 
      :controller => controller.controller_name,
      :resource_name => template.resource_name,
      :title => title
    }
  end

  def render_options
    {
      :layout => '/layouts/toolbox',
      :partial => partial,
    }
  end

  def controller
    template.send(:controller)
  end

  def request
    template.send(:request)
  end
end
