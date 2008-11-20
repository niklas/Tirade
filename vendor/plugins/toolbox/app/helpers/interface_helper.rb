module InterfaceHelper
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
    dom = opts.delete(:id) || 'accordion'
    concat content_tag( :div, capture(&block), :id => dom, :class => 'accordion'), block.binding
  end

  def accordion_item(title="Accordion Item", opts={}, &block)
    tag2 = opts.delete(:content_tag) || :dl
    add_class_to_html_options(opts, 'accordion_content')
    toggle_class = "accordion_toggle #{title.urlize}"
    concat content_tag(:h3,title, :class => toggle_class, :name => title.urlize), block.binding
    concat content_tag(tag2,capture(&block), opts), block.binding
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
    return '' if thing.nil?
    content_tag :li, 
      single_item(thing, opts),
      :class => "#{dom_id(thing)} #{thing.table_name.singularize} #{toolbox_item_cycle}"
  end

  def single_item(thing, opts={})
    partial = opts[:partial] || 'list_item'
    partial = "/#{thing.table_name}/#{partial}" unless partial =~ %r~^/~
    render( :partial => partial, :object => thing, :locals => {:model => thing})
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

  # Makes sure that the given class is in the options which are used for
  # tag helpers like content_tag, link_to etc.
  def add_class_to_html_options(options,name)
    if options.has_key? :class
      return if name =~ /^odd|even$/ && options[:class] =~ /odd|even/
      options[:class] += " #{name}"
    else
      options[:class] = name.to_s
    end
    options
  end

  # helps to genric find the current_model in @model or @#{ressource}
  def current_model
    model
  end

  # We carry the name of the resource in the di@title
  def show(obj,name,opts={}, &block)
    label = opts.delete(:label) || _(name.to_s.humanize)
    label = nil if opts.delete(:skip_label)
    selectable = opts.delete(:selectable)
    add_class_to_html_options(opts, 'selectable') if selectable
    add_class_to_html_options(opts, name.to_s)
    opts[:title] ||= name.to_s
    opts[:dd] ||= {}

    if block_given? || !obj.respond_to?(name)
      concat di_dt_dd(label, capture(&block), opts), block.binding
    else
      val = obj.send(name) rescue "unknow attr: #{obj.class}##{name}"
      if val.is_a?(ActiveRecord::Base)
        # url_for does not recognize STI :(
        opts[:href] = url_for(:controller => val.table_name, :id => val.id, :action => 'show') if selectable
        add_class_to_html_options(opts[:dd], dom_id(val))
        add_class_to_html_options(opts[:dd], 'record')
        val = render_as_attribute(val)
      elsif val.is_a?(Array)
        unless val.blank?
          opts[:href] = url_for(:controller => val.first.table_name) if selectable
          add_class_to_html_options(opts, 'list')
        end
        val = list_of(val)
      elsif val.is_a?(ActsAsConfigurable::OptionsProxy)
        val = 
          content_tag(
            :dl,
            val.values.collect do |key, value|
              di_dt_dd(key,value,:class => dom_class(value))
            end.join,
            :class => 'hash'
        )
      end
      val = debug(val) unless val.is_a?(String)
      di_dt_dd(label, val, opts)
    end
  end

  def render_as_attribute(record)
    return 'none' if record.nil?
    render(:partial => "/#{record.table_name}/attribute", :object => record)
  end

  def di_dt_dd(dt,dd, opts={})
    dd_opts = opts.delete(:dd)
    add_class_to_html_options(opts, toolbox_row_cycle)
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
end
