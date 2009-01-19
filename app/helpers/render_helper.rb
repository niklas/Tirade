# The RenderHelper should contain all the helpers to render Pages, Grids, Randerings and Parts
module RenderHelper
  def warning(message)
    content_tag(:div, message, :class => 'warning')
  end
  def render_rendering(rendering)
    clss = "rendering #{rendering.part.andand.filename}"
    content_tag(
      :div,
      if rendering.part.nil?
        clss += ' without_part'
        warning('No Part assigned, drop one here.')
      elsif !rendering.has_content?
        clss += ' without_content'
        warning("No #{rendering.part.preferred_types.to_sentence(:connector => 'or')} assigned, drop one here.")
      else
        clss += " #{rendering.content.class.to_s.underscore}"
        rendering.part.render_with_content(rendering.content,rendering.options.to_hash)
      end,
      :id => dom_id(rendering), :class => clss
    )
  end

  # Renders the given grid and all its containing grids
  # warning: recursive
  def render_grid(grid,opts = {}, &block)
    if grid.children.empty?
      inner = block_given? ? yield(grid) : h(grid.inspect.to_s)
    else
      inner = grid.visible_children.collect do |child| 
        render_grid(child,opts,&block)
      end.join(' ')
    end
    render_grid_filled_with(grid,inner,opts)
  end

  # Renderings just the grid container
  def render_grid_filled_with(grid,inner,opts={})
    opts = opts.dup
    grid.yuies.each do |yui_class|
      add_class_to_html_options(opts, yui_class)
    end
    if opts.delete(:active) == grid
      add_class_to_html_options(opts, 'active')
    end
    add_class_to_html_options(opts, dom_id(grid))
    opts[:id] = dom_id(grid) # unless opts[:id].nil?
    content_tag( :div, inner, opts)
  end

  def render_grid_in_page(thegrid,thepage, opts = {})
    render_grid_filled_with(
      thegrid,
      if thegrid.visible_children.empty?
        renderings = thepage.renderings.for_grid(thegrid)
        unless renderings.empty?
          renderings.collect do |rendering|
            # FIXME HACK rendering must know about trailing path, this is in da page
            rendering.page = thepage
            rendering.render 
          end
        else
          []
        end
      else
        thegrid.visible_children.collect do |child|
          render_grid_in_page(child,thepage)
        end
      end.join(' '),
      opts
    )
  end

  def render_page(thepage)
    if layout = thepage.final_layout
      content_tag(
        :div,
        layout.render_in_page(thepage),
        {:id => thepage.yui, :class => "page #{dom_id(thepage)}"}
      )
    else
      page_without_layout_warning(thepage)
    end
  end

  def page_without_layout_warning(thepage)
    content_tag(:div,
                'Page has no Layout, drop one',
                :class => 'warning page_without_layot')
  end

  def remove_page
    page.select(Page::Types.keys.collect {|t| "div##{t}"}.join(', ')).remove
  end

  def clear
    remove_page
    page.select("body > .header, body > .footer, body > .admin, body > .error").remove
  end

  def insert_page(thepage)
    page.select('body').prepend render(:inline => "<%= render_page(thepage) %>" , :locals => {:thepage => thepage})
  end
end
