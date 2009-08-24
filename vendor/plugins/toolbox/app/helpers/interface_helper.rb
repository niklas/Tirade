module InterfaceHelper
  include UtilityHelper
  include TextFilter # for markup

  # Opens up a Wrapper for an +accordion+ with 1 or more +acction_item+s. Use it as a block
  # with <% %> tags around it (no '=')
  #   <% accorion do %>
  #     <% accordion_item "One" do %>
  #       One Content Here
  #     <% end %>
  #     <% accordion_item "Two" do %>
  #       Two Content Here
  #     <% end %>
  #   <% end %>
  def accordion(opts={}, &block)
    add_class_to_html_options(opts, 'accordion')
    concat content_tag( :div, capture(&block), opts)
  end

  def accordion_item(title="Accordion Item", opts={}, &block)
    tag2 = opts.delete(:content_tag) || :dl
    add_class_to_html_options(opts, 'accordion_content')
    add_class_to_html_options(opts, 'ui-helper-clearfix')
    toggle_class = "accordion_toggle #{title.urlize}"
    concat content_tag(:h3,title, :class => toggle_class, :name => title.urlize)
    concat content_tag(tag2,capture(&block), opts)
  end

  # Creates a bar of links (get it later  per yield(:linkbar), as seen in /layouts/_toolbox
  #    <% links do %>
  #      <li><%= link_to "Home", root_url %></li>
  #      <%= li_link_to "Home", root_url %>
  #    <% end %>
  def links(content=nil,opts={}, &block)
    content_for(:linkbar, capture(&block))
  end

  # like #links, but for the bottom
  def bottom_links(content=nil,opts={}, &block)
    content_for(:bottom_linkbar, capture(&block))
  end

  def li_link_to(name, options = {}, html_options = nil)
    content_tag(:li,link_to(name,options,html_options))
  end

  def li_link_to_remote(name, options = {}, html_options = nil)
    content_tag(:li,link_to_remote(name,options,html_options))
  end

  # You need a partial '/resources/list_item' and must NOT write the +li+
  def list_of(things,opts={})
    raise ArgumentError, 'got nil list of things' if things.nil?
    if !opts.delete(:force_list) && things.empty?
      content_tag(:span,'none',opts)
    else
      kind = things.first.table_name rescue 'items'
      add_class_to_html_options(opts, kind)
      add_class_to_html_options(opts, 'records') if things.first.andand.is_a?(ActiveRecord::Base)
      add_class_to_html_options(opts, 'list')
      add_class_to_html_options(opts, 'empty') if things.blank?
      content_tag(
        :ul,
        things.collect do |thing|
          list_item(thing, opts)
        end.join(' '),
        opts
      )
    end
  end

  def list_item(thing,opts={})
    return '' unless thing
    if thing.is_a?(ActiveRecord::Base)
      content_tag :li, 
        single_item(thing, opts),
        :class => "record #{dom_id(thing)} #{thing.table_name.singularize} #{toolbox_item_cycle}", :rel => dom_id(thing),
        :title => h(thing.title)
    else
      content_tag :li, 
        show_value(thing, opts),
        :class => "#{thing.class.to_s.domify} #{toolbox_item_cycle}", :rel => thing.class.to_s.domify
    end
  end

  def single_item(thing, opts={})
    partial = opts[:partial] || 'list_item'
    partial = "/#{thing.table_name}/#{partial}" unless partial =~ %r~^/~
    icon_for(thing) + 
    render( :partial => partial, :object => thing, :locals => {:model => thing, thing.table_name.singularize.to_sym => thing}) +
    show_link_to(thing)
  end

  def icon_for(thing)
    name = case thing
           when String
             thing.underscore
           else
             thing.respond_to?(:icon_name) ? thing.icon_name : thing.class_name.underscore 
           end
    path = thing.respond_to?(:icon_path) ? thing.icon_path : %Q~icons/types/#{name}.png~
    image_tag(path, :class => 'icon')
  end

  # You need a partial '/resources/table_row' and must write the +tr+
  def table_of(things,opts={})
    kind = things.first.table_name
    # columns = things.first.visible_columns
    add_class_to_html_options(opts, kind)
    content_tag(
      :table,
      render(:partial => "/#{kind}/table_row", :collection => things),
      opts
    )
  end

  # You need a partial '/resources/accordion_item' and should call the
  # helper +accordion_item+ from there using a block.
  def accorion_of(things,opts={})
    kind = things.first.table_name
    add_class_to_html_options(opts, kind)
    add_class_to_html_options(opts, "accordion")
    content_tag(
      :div,
      render(:partial => "/#{kind}/accordion_item", :collection => things),
      opts
    )
  end

  # helps to genric find the current_model in @model or @#{ressource}
  def current_model
    model
  end

  # We carry the name of the resource in the di@title
  def show(obj,name,opts={}, &block)
    label = opts.delete(:label) || _(name.to_s.humanize)
    label = nil if opts.delete(:skip_label)
    add_class_to_html_options(opts, name.to_s)
    opts[:title] ||= name.to_s
    opts[:dd] ||= {}

    if block_given?
      concat di_dt_dd(label, capture(&block), opts)
    else

      begin
        val = obj.send(name) 
      rescue NoMethodError
        return content_tag(:span, "unknow attr: #{obj.class}##{name}", :class => 'warning')
      end

      begin
        val = show_value(val,opts)
      rescue Exception => e
        logger.debug("cannot show #{obj.class}##{name}: #{h e.message}\n#{e.backtrace.join("\n")}")
        return content_tag(:span, "cannot show #{obj.class}##{name}: #{h e.message}", :class => 'warning')
      end

      if val.is_a?(String) and obj.markup?(name)
        val = markup(val)
      end
      val = "(#{val.class})\n#{debug(val)}" unless val.is_a?(String)
      di_dt_dd(label, val, opts)
    end
  end

  def show_value(val, opts={})
    selectable = opts.delete(:selectable)
    add_class_to_html_options(opts, 'selectable') if selectable
    case val
    when ActiveRecord::Base
      # url_for does not recognize STI :(
      opts[:href] = url_for(:controller => val.table_name, :id => val.id, :action => 'show') if selectable
      add_class_to_html_options(opts[:dd], dom_id(val))
      add_class_to_html_options(opts[:dd], 'record')
      add_class_to_html_options(opts, 'record')
      render_as_attribute(val)
    when Hash, HashWithIndifferentAccess
      content_tag(
        :dl,
        val.collect do |key, value|
          di_dt_dd(key, (value.blank? ? 'blank' : value))
        end.join,
        :class => 'hash'
      )
    when Array, ActiveRecord::NamedScope::Scope, ActiveRecord::Associations::AssociationProxy
      unless val.blank?
        opts[:href] = url_for(:controller => val.first.table_name) if selectable
        add_class_to_html_options(opts, 'list')
      end
      list_of(val)
    when ActsAsConfigurable::OptionsProxy
      content_tag(
        :dl,
        val.values.collect do |key, value|
          di_dt_dd(key,value,:class => dom_class(value))
        end.join,
        :class => 'hash'
      )
    when Time, Date
      val.to_s(:db)
    when String
      val
    when Fixnum
      val.to_s
    when Float
      val.to_s
    else
      debug(val)
    end
  end

  def render_as_attribute(record)
    return 'none' if record.nil?
    partial = 'attribute'
    begin
      render(:partial => "/#{record.table_name}/#{partial}", :object => record)
    rescue ActionView::MissingTemplate => e
      if partial == 'attribute'
        partial = 'list_item'
        retry
      else
        return 'no partial found'
      end
    end
  end

  def di_dt_dd(dt,dd, opts={})
    dd_opts = opts.delete(:dd)
    add_class_to_html_options(opts, toolbox_row_cycle)
    add_class_to_html_options(opts, 'ui-corner-all')
    add_class_to_html_options(opts, 'ui-helper-clearfix')
    content_tag(:di,
                (dt.blank? ? '' : content_tag(:dt, dt)) +
                content_tag(:dd, dd, dd_opts),
                opts
               )
  end

  def toolbox_row_cycle
    cycle('odd', 'even', :name => 'toolbox_rows')
  end

  def toolbox_item_cycle
    cycle('odd', 'even', :name => 'list_items')
  end

  def back_link(label='Back',opts={})
    add_class_to_html_options(opts, 'back')
    li_link_to label, '#', opts
  end


  def live_search_for(resource, opts={})
    inner = ''
    add_class_to_html_options opts, 'live_search'
    if resource.is_a? Array
      urls_for_select = resource.collect {|r| [r.humanize, url_for(:controller => r.classify.constantize.table_name)]}

      inner << select_tag("polymorph_search_url", options_for_select(urls_for_select), :class => 'polymorph_search_url')
      inner << text_field_tag("polymorph_search_term", nil, :href => urls_for_select.first.last, :class => 'search_term')

      resources_css = resource.collect {|r| r.classify.constantize.table_name}.uniq.join(' ')
      inner << content_tag(:div, "Search for #{resource.collect(&:pluralize).to_sentence}", :class => "search_results #{resources_css}")

      add_class_to_html_options opts, 'polymorphic'
    else
      singular = resource.to_s
      plural = singular.pluralize
      inner << text_field_tag("#{resource}_search_term", nil, :href => opts[:href] || url_for(:controller => plural), :class => 'search_term')
      inner << content_tag(:div, "Search for #{plural.humanize}", :class => "search_results #{plural}")
    end

    link_to("search", '#', :class => 'toggle_live_search') +
    content_tag(:div, inner, opts )
  end

  def live_search_for_reflection(reflection, opts = {})
    live_search_for(
      reflection.name, 
      opts.merge(
        :href => url_for(:controller => reflection.class_name.tableize)
      )
    )
  end

  # Renders the views for alle actings defined on the model class
  def actings_for(record)
    returning '' do |html|
      record.acting_roles.each do |role|
        view_path = record.class.acting_view_path(role)
        if File.exists?(view_path)
          html << @template.render(:file => view_path, :locals => {:object => record, :record => record})
        end
      end
    end
  end

end
