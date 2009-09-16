# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  ToolboxContent = 'toolbox_content'

  def controller_name
    controller.controller_name
  end

  # just a placeholder for translations (localisation plugin)
  def _(phrase)
    phrase
  end

  def content_given?(name) 
    ! instance_variable_get("@content_for_#{name}").nil?
  end 
  
  def flash_messages
    [:notice, :warning, :message, :error].map do |f|
      content_tag(:div, flash[f], :id => 'flash', :class => "#{f.to_s}") if flash[f]
    end.join
  end

  def warning_tag(text)
    content_tag(:div,text,{:class => 'warning'})
  end

  def error_tag(opts={}, &block)
    add_class_to_html_options opts, 'ui-corner-all'
    add_class_to_html_options opts, 'ui-state-error'
    concat widget_tag(
      content_tag(:div, capture(&block), opts), :class => 'error'
    )
  end

  def widget_tag(content, opts={})
    add_class_to_html_options opts, 'ui-widget'
    content_tag(:div, content, opts)
  end

  def public_content_link(content,opts = {})
    content = Page.find_by_url(content) if content.is_a?(String)
    return "[link target not found]" unless content
    label = opts.delete(:label) || content.title
    url = public_content_path(content, opts)
    link_to(label, url, opts)
  end
  alias :public_page_link :public_content_link

  def public_content_path(content, opts={})
    path = content.path
    path += [opts.delete(:item_id)] if opts.has_key?(:item_id)
    url_for(:path => path, :action => 'index', :controller => 'public')
  end

  def public_item_link_with_scaled_image(item,geom)
    parent = item.parent
    public_page_link(parent.title, :item_id => item.id, :label => scaled_image_tag(item,geom))
  end

  # copied without shame from http://blog.vixiom.com/2007/06/05/rails-helper-for-swfobject/
  def swf_object(swf, id, width, height, flash_version, background_color, params = {}, vars = {}, create_div = false)
    # create div ?
    create_div ? output = "<div id=’#{id}‘>This website requires <a href=’http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash&promoid=BIOW’ target=’_blank’>Flash player</a> #{flash_version} or higher.</div><script type=’text/javascript’>" : output = "<script type=’text/javascript’>"
    output << "var so = new SWFObject(’#{swf}‘, ‘#{id}‘, ‘#{width}‘, ‘#{height}‘, ‘#{flash_version}‘, ‘#{background_color}‘);"
    params.each  {|key, value| output << "so.addParam(’#{key}‘, ‘#{value}‘);"}
    vars.each    {|key, value| output << "so.addVariable(’#{key}‘, ‘#{value}‘);"}
    output << "so.write(’#{id}‘);"
    output << "</script>"
  end


  def show_link_to(thingy, options = {})
    link_to_show(thingy, options)
  end

  def link_to_show(thingy, options={})
    label = options.delete(:label) || "Show #{title_for thingy}"
    singular = thingy.class.name.underscore
    add_class_to_html_options(options, 'show')
    add_class_to_html_options(options, "show_#{singular}")
    add_class_to_html_options(options, dom_id(thingy))
    add_class_to_html_options(options, singular)

    prms = options.delete(:params) || {}
    url_method = "#{singular}_path"
    url = send(url_method, thingy, prms)
    link_to(label, url, options)
  end

  def index_link_to(klass, options = {})
    label = options.delete(:label) || klass.to_s.pluralize.humanize
    add_class_to_html_options(options, 'index')
    add_class_to_html_options(options, "index_#{klass.controller_name}")
    add_class_to_html_options(options, klass.controller_name)
    link_to(label, {:controller => klass.controller_name}, options)
  end

  def link_to_index(klass, options={})
    index_link_to(klass, options)
  end

  def link_to_new(klass, options = {})
    singular = klass.name.underscore
    label = options.delete(:label) || "new #{singular.humanize}"
    add_class_to_html_options(options, 'new')
    add_class_to_html_options(options, "new_#{singular}")
    add_class_to_html_options(options, klass.controller_name)

    prms = options.delete(:params) || {}
    url_method = "new_#{singular}_path"
    url = send(url_method, prms)
    link_to(label, url, options)
  end

  def link_to_edit(thingy, options={})
    label = options.delete(:label)  || "Edit #{title_for(thingy)}"
    singular = thingy.class.name.underscore
    add_class_to_html_options(options, 'edit')
    add_class_to_html_options(options, "edit_#{singular}")
    add_class_to_html_options(options, dom_id(thingy))
    add_class_to_html_options(options, singular)

    prms = options.delete(:params) || {}
    url_method = "edit_#{singular}_path"
    return unless respond_to?(url_method)
    url = send(url_method, thingy, prms)
    link_to(label, url, options)
  end

  def link_to_destroy(thingy, options={})
    label = options.delete(:label) || "Destroy #{title_for(thingy)}"
    singular = thingy.class.name.underscore
    add_class_to_html_options(options, 'destroy')
    add_class_to_html_options(options, "destroy_#{singular}")
    add_class_to_html_options(options, dom_id(thingy))
    add_class_to_html_options(options, singular)

    if false # disable js from rails .. will make ajax request from jquery.toolbox
      options[:confirm] ||= "Really #{label}?"
      options[:method] = :delete
    end

    url_method = "#{singular}_path"
    url = send(url_method, thingy)
    link_to(label, url, options)
  end

  def link_to_cancel(label='Cancel')
    link_to_function label do |page|
      page.toolbox.pop
    end
  end

  def link_to_ok(label='OK')
    link_to_function label do |page|
      page.toolbox.pop
    end
  end

  def title_for(thingy)
    thingy.andand.title || "#{thingy.class} ##{thingy.id}"
  end

  def session_key_name
    ActionController::Base.session_options[:key]
  end

end
