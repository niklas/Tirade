class ExceptionFrameRenderer < FrameRenderer
  attr_reader :exception
  def initialize(exception, template, opts={})
    @exception = exception
    super(template, opts)
  end
  def css
    super + %w(error exception)
  end
  def render_options
    partial = controller.rescue_templates[exception.class.name]
    super.merge({
      :object => exception,
      :partial => "/toolbox/#{partial}"
    })
  end
  def title
    case exception
    when ActionView::TemplateError
      <<-EOTITLE 
        #{exception.original_exception.class.name} in
        #{request.parameters["controller"].andand.capitalize}
        ##{request.parameters["action"]}
      EOTITLE
    else
      exception.class.name
    end
  end
  def links
    [
      template.link_to_ok
    ]
  end
end
