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
    concat content_tag(:h3,title, :class => toggle_class), block.binding
    concat content_tag(tag2,capture(&block), opts), block.binding
  end

  # Creates a bar of links
  #    <% links do %>
  #      <li><%= link_to "Home", root_url %></li>
  #      <%= li_link_to "Home", root_url %>
  #    <% end %>
  def links(content=nil,opts={}, &block)
    inner ||= capture(&block)
    add_class_to_html_options(opts, 'linkbar')
    html = content_tag(:ul, inner, opts)
    concat html, block.binding if block_given?
    html
  end

  def li_link_to(name, options = {}, html_options = nil)
    content_tag(:li,link_to(name,options,html_options))
  end

  def li_link_to_remote(name, options = {}, html_options = nil)
    content_tag(:li,link_to_remote(name,options,html_options))
  end

  # You need a partial '/resources/list_item' and must write the +li+
  def list_of(things,opts={})
    kind = things.first.table_name
    partial = opts[:partial] || 'list_item'
    partial = "/#{kind}/#{partial}" unless partial =~ %r~^/~
    add_class_to_html_options(opts, kind)
    content_tag(
      :ul,
      render(:partial => partial, :collection => things),
      opts
    )
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
      options[:class] += " #{name}"
    else
      options[:class] = name
    end
    options
  end

  # helps to genric find the current_model in @model or @#{ressource}
  def current_model
    @model || instance_variable_get("@#{@controller.controller_name.singularize}") || raise("no model loaded")
  end

  def show(obj,name,opts={}, &block)
    label = opts[:label] || _(name.to_s.humanize)
    val = obj.send(name)
    unless val.blank?
      if block_given?
        concat di_dt_dd(label, capture(&block)), block.binding
      else
        di_dt_dd(label, val)
      end
    end
  end

  def di_dt_dd(dt,dd)
    content_tag(:di,
                content_tag(:dt, dt) +
                content_tag(:dd, dd),
                :class => toolbox_row_cycle
               )
  end

  def toolbox_row_cycle
    cycle('odd', 'even', :name => 'toolbox_rows')
  end
end
