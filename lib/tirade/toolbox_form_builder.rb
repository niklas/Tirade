class ToolboxFormBuilder < ActionView::Helpers::FormBuilder
  include Tirade::UnwrappedFormBuilderFields
  include Tirade::FormBuilderHelper
  def submit(label="Submit", opts={})
    if @object.new_record?
      super('Create', :class => 'submit create', :title => 'Create')
    else
      super('Save', :class => 'submit save', :title => 'Save')
    end
  end

  def wrap(field, options, tag_output)
    label = @template.content_tag(
      :label,
      (options.delete(:label) || field.to_s.humanize),
      {:for => "#{@object_name.to_s}_#{field}"}
    )
    @template.add_class_to_html_options(options, field.to_s)
    @template.di_dt_dd(label,tag_output,options)
  end
end
