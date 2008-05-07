class NormalFormBuilder < ActionView::Helpers::FormBuilder

  def text_field(field, options = {})
    wrap(field, options, super(field,options))
  end

  def text_area(field, options = {})
    wrap(field, options, super(field,options))
  end

  def collection_select(field, collection, value_method, text_method, options = {}, html_options = {})
    wrap(field, options, super(field, collection, value_method, text_method, options, html_options))
  end

  def select(field, choices, options = {}, html_options = {})
    wrap(field,options, super(field, choices, options, html_options))
  end

  def check_box(field, options = {}, checked_value = "1", unchecked_value = "0")
    wrap(field, options,super(field, options, checked_value, unchecked_value))
  end

  private
  def wrap(field, options, tag_output)
    label = @template.content_tag(
      :label,
      (options.delete(:label) || field.to_s.humanize),
      {:for => "#{@object_name.to_s}_#{field}"}
    )
    @template.content_tag(
      :p,
      label + ' ' + tag_output,
      {:class => field.to_s}
    )
  end
end
