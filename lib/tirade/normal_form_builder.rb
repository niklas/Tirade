class NormalFormBuilder < ActionView::Helpers::FormBuilder

  def text_field(method, options = {})
    wrap(method, options, super(method,options))
  end

  def text_area(method, options = {})
    wrap(method, options, super(method,options))
  end

  private
  def wrap(method, options, tag_output)
    label = @template.content_tag(
      :label,
      (options.delete(:label) || method.to_s.humanize),
      {:for => "#{@object_name.to_s}_#{method}"}
    )
    @template.content_tag(
      :p,
      label + ' ' + tag_output
    )
  end
end
