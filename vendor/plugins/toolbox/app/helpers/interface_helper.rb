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
    if things.empty?
      content_tag(:span,'none',opts)
    else
      kind = things.first.table_name
      partial = opts[:partial] || 'list_item'
      partial = "/#{kind}/#{partial}" unless partial =~ %r~^/~
      add_class_to_html_options(opts, kind)
      add_class_to_html_options(opts, 'list')
      content_tag(
        :ul,
        things.collect do |thing|
          content_tag :li,
            render(:partial => partial, :object => thing, :locals => {:model => thing}),
            :class => "#{kind.singularize} #{toolbox_item_cycle}"
        end.join(' '),
        opts
      )
    end
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
      options[:class] = name.to_s
    end
    options
  end

  # helps to genric find the current_model in @model or @#{ressource}
  def current_model
    @model || instance_variable_get("@#{@controller.controller_name.singularize}") || raise("no model loaded")
  end

  # We carry the name of the resource in the di@title
  def show(obj,name,opts={}, &block)
    label = opts.delete(:label) || _(name.to_s.humanize)
    selectable = opts.delete(:selectable)
    add_class_to_html_options(opts, 'selectable') if selectable
    add_class_to_html_options(opts, name.to_s)
    opts[:title] ||= name.to_s

    if block_given? || !obj.respond_to?(name)
      concat di_dt_dd(label, capture(&block), opts), block.binding
    else
      val = obj.send(name) rescue "unknow attr: #{obj.class}##{name}"
      if val.is_a?(ActiveRecord::Base)
        opts[:href] = url_for(:controller => val.table_name) if selectable
        val = render(:partial => "/#{val.table_name}/attribute", :object => val)
      elsif val.is_a?(Array)
        unless val.blank?
          opts[:href] = url_for(:controller => val.first.table_name) if selectable
          add_class_to_html_options(opts, 'list')
        end
        val = list_of(val)
      end
      di_dt_dd(label, val, opts)
    end
  end

  def di_dt_dd(dt,dd, opts={})
    add_class_to_html_options(opts, toolbox_row_cycle)
    content_tag(:di,
                content_tag(:dt, dt) +
                content_tag(:dd, dd),
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
