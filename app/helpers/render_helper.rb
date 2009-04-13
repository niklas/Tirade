# The RenderHelper should contain all the helpers to render Pages, Grids, Randerings and Parts
module RenderHelper
  def warning(message)
    content_tag(:div, message, :class => 'warning')
  end
  def render_rendering(rendering)
    clss = "rendering #{rendering.part.andand.filename} #{dom_id rendering}"
    content_tag(
      :div,
      # No Content
      if !rendering.has_content?      
        # but thats ok, can show without content (plain html)
        if rendering.part && rendering.part.preferred_types.blank?
          rendering.part.render(rendering.final_options, rendering.context_in_registers)
        else
          clss += ' without_content'
          render(:partial => 'renderings/without_content', :object => rendering)
        end
      # Content, but no Part
      elsif rendering.part.nil?
        clss += ' without_part'
        render(:partial => 'renderings/without_part', :object => rendering)
      # has Part and Content
      else
        clss += " #{rendering.content.class.to_s.underscore}"
        rendering.part.render_with_content(rendering.content,rendering.final_options,rendering.context_in_registers)
      end,
      :id => dom_id(rendering), :class => clss, :rel => dom_id(rendering)
    )
  end

  # Renders the given grid and all its containing grids
  # warning: recursive
  def render_grid(grid,opts = {}, &block)
    if grid.children.empty?
      inner = block_given? ? yield(grid) : grid.label
    else
      inner = grid.visible_children_with_css.collect do |child, css| 
        render_grid(child, opts.merge(:wrapper => css), &block)
      end.join(' ')
    end
    render_grid_filled_with(grid,inner,opts)
  end

  # Renderings just the grid container, inner_html must be given
  # Inner can be wrapped in a div, just give :wrapper => 'css_class'
  def render_grid_filled_with(grid, inner_html, opts={})
    opts = opts.dup
    add_class_to_html_options(opts, grid.own_css)
    add_class_to_html_options(opts, 'grid')
    add_class_to_html_options(opts, 'active') if opts[:active] == grid
    add_class_to_html_options(opts, dom_id(grid))
    add_class_to_html_options(opts, grid.title.domify)
    opts[:id] = dom_id(grid) # unless opts[:id].nil?
    opts[:rel] = dom_id(grid)
    if wrapper = opts.delete(:wrapper)
      div_wrap( content_tag(:div, inner_html, opts), wrapper)
    else
      content_tag(:div, inner_html, opts)
    end
  end

  # Renders a Grid with all Renderings visible on given page
  def render_grid_in_page(thegrid,thepage, opts = {})
    render_grid_filled_with(
      thegrid,
      if thegrid.visible_children.empty?
        renderings = thepage.renderings_for_grid(thegrid)
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
        thegrid.visible_children_with_css.collect do |child, css|
          render_grid_in_page( child, thepage, opts.merge(:wrapper => css) )
        end
      end.join("\n"),
      opts
    )
  end

  def div_wrap(inner, css, opts={})
    add_class_to_html_options(opts, css)
    content_tag( :div, inner, opts)
  end

  # Renders the hole Page with Grids and their Renderings
  def render_page(thepage)
    if layout = thepage.final_layout
      div_wrap(
        content_tag(
          :div,
          layout.render_in_page(thepage),
          {:class => "page #{dom_id(thepage)}"}
        ),
        'page_margins', :style => thepage.style
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
    page.select('body > div.page_margins').remove
  end

  def clear
    remove_page
    page.select("body > .header, body > .footer, body > .admin, body > .error").remove
  end

  def insert_page(thepage)
    page.select('body').prepend render(:inline => "<%= render_page(thepage) %>" , :locals => {:thepage => thepage})
  end
end
