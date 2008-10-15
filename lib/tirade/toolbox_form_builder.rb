class ToolboxFormBuilder < ActionView::Helpers::FormBuilder
  include Tirade::FormBuilderHelper
  def submit(label="Submit", opts={})
    if @object.new_record?
      super('Create', :class => 'submit create')
    else
      super('Save', :class => 'submit save')
    end
  end
end
