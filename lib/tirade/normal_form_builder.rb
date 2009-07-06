class NormalFormBuilder < ActionView::Helpers::FormBuilder
  include Tirade::UnwrappedFormBuilderFields
  include Tirade::FormBuilderHelper


  def submit(label="Submit", opts={})
    html = []

    controller = @object_name.to_s.pluralize
    if @object.new_record?
      html << super('Create', :class => 'submit create')
      html << @template.link_to('cancel', {:controller => controller}) 
    else
      html << super('Save', :class => 'submit save')
      html << @template.link_to('cancel', {:controller => controller, :action => 'show', :id => @object}, :class => "show #{@object_name} back") 
    end
    html
  end
end
