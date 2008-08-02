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
    options[:class] ||= ''
    options[:class] += ' checkbox'
    wrap(field, options,super(field, options, checked_value, unchecked_value))
  end

  def select_picture
    unless @object.class.reflections.has_key?(:picturizations)
      return 'does not know about pictures'
    end
    inner = ''
    inner << "Search + click to add/remove pictures for '#{@object.title}'"

    list_dom = "pictures_list"
    inner << @template.content_tag(:div,@template.render(:partial => '/images/for_select', :collection => @object.images), {:id => list_dom, :class => 'pictures_list'})

    inner << @template.text_field_tag('search_images')
    results_dom = "search_results"
    inner << @template.content_tag(:div,'results', {:id => results_dom, :class => 'pictures_list'})
    inner << @template.hidden_field_tag("#{@object_name}[image_ids][]","empty")
    wrap('select picture', {}, inner)
  end

  def define_options
    wrap('Define Options', {}, super)
  end

  def select_options
    wrap('Options', {}, super)
  end

  def submit(label="Submit", opts={})
    html = []
    if @object.new_record?
      html << super('Create', :class => 'submit create')
      html << @template.link_to('cancel', {:controller => @object_name.pluralize}) 
    else
      html << super('Save', :class => 'submit save')
      html << @template.link_to('cancel', @object) 
      html << @template.link_to('back', {:controller => @object_name.pluralize}) 
    end
    html.map {|b| @template.content_tag(:li,b)}.join(' ')
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
