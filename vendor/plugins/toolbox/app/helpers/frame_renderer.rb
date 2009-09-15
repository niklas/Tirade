class FrameRenderer
  attr_reader :thingy, :template, :partial, :options
  def initialize(thingy, partial, template, options={})
    @thingy = thingy
    @template = template
    @partial = partial || default_partial
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

  def default_partial
    'show'
  end

  def links
    []
  end

  def add_links
    links.each do |link|
      template.content_for :linkbar, link
    end
  end


  def to_s
    template.content_tag(:div, inner, html_options)
  end

  def inner
    begin
      template.render render_options
    rescue ActionView::MissingTemplate => e
      if !partial.starts_with?('/')
        @partial = "/#{partial}"
        retry
      else
        raise e
      end
    end
  end

  def html_options
    css.each do |clss|
      template.add_class_to_html_options options, clss
    end
    options[:data] = meta.to_json
    options
  end

  def partial_name
    if partial.index('/')
      partial.split('/').last
    else
      partial
    end
  end

  def css
    ['frame']
  end

  def action
    (options[:action] || controller.action_name).to_s
  end

  def meta
    {
      :href => request.url, 
      :action => action, 
      :controller => controller.controller_name
    }
  end

  def render_options
    {
      :layout => '/layouts/toolbox',
      :object => thingy,
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
