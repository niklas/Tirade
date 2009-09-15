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
