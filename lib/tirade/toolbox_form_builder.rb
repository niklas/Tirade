class ToolboxFormBuilder < ActionView::Helpers::FormBuilder
  include Tirade::UnwrappedFormBuilderFields
  include Tirade::FormBuilderHelper
  def submit(label="Submit", opts={})
    if @object.new_record?
      label ||= 'Create'
      super(label, :class => 'submit create', :title => label)
    else
      label ||= 'Save'
      super(label, :class => 'submit save', :title => label)
    end
  end

  def wrap(field, options, tag_output)
    @template.add_class_to_html_options(options, field.to_s)
    label = label_for(field, options.delete(:label))
    @template.di_dt_dd(label,tag_output,options)
  end
end
