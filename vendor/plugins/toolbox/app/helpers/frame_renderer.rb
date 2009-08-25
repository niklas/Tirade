class FrameRenderer
  attr_reader :thingy, :template, :partial, :options
  def initialize(thingy, partial, template, options={})
    @thingy = thingy
    @template = template
    @partial = partial
    @options = options
  end

  def self.for(thingy, partial, template, opts={})
    if thingy.respond_to?(:each)
      CollectionFrameRenderer.new(thingy, partial, template, opts)
    else
      RecordFrameRenderer.new(thingy, partial, template, opts)
    end
  end

  def to_s
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
    ['frame', partial]
  end

  def meta
    {
      :href => template.send(:request).url, 
      :action => controller.action_name, 
      :controller => controller.controller_name
    }
  end

  def render_options
    {
      :layout => '/layouts/toolbox',
      :object => thingy,
      :partial => "/#{partial}"
    }
  end

  def controller
    template.send(:controller)
  end
end

class RecordFrameRenderer < FrameRenderer
  alias_method :record, :thingy
  def meta
    super.merge({
      :title => record.title || "#{record.class_name} ##{record.id}", 
      :resource_name => template.resource_name,
      :id => record.id
    })
  end

  def render_options
    super.merge({
      :locals => record ? {
        template.resource_name.to_sym => record
      } : nil
    })
  end

  def css
    css = super
    css << 'edit' if partial == 'form'
    if record.respond_to?(:resource_name)
      css << 'new' if record.new_record?
      css << template.dom_id(record)
      css << record.resource_name
    end
    css
  end
end

class CollectionFrameRenderer < FrameRenderer
  alias_method :collection, :thingy
  def meta
    super.merge({
      :title => template.human_name.pluralize,
      :resource_name => template.resource_name
    })
  end
  def render_options
    super.merge({
      :locals => collection ? {
        template.resource_name.pluralize.to_sym => collection
      } : nil
    })
  end

  def css
    css = super
    css << 'index'
    css << collection.first.resource_name unless collection.empty?
  end
end

class ExceptionFrameRenderer < FrameRenderer
  alias_method :exception, :thingy
  def initialize(*args)
    super
    @partial = ApplicationController.rescue_templates[exception.class.name]
  end
  def css
    super + %w(error exception)
  end
  def render_options
    super.merge({
      :partial => "/toolbox/#{partial}"
    })
  end
  def meta
    title = case exception
            when ActionView::TemplateError
              <<-EOTITLE 
                #{exception.original_exception.class.name} in
                #{request.parameters["controller"].andand.capitalize}
                ##{request.parameters["action"]}
              EOTITLE
            else
              exception.class.name
            end
    super.merge({
      :title => title
    })
  end
end
