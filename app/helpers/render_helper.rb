# The RenderHelper should contain all the helpers to render Pages, Grids, Randerings and Parts
module RenderHelper
  def render_rendering(rendering)
    render_rendering_filled_with(
      rendering,
      if rendering.part.nil?
        content_tag(:div, 'no part assigned', {:class => 'warning'})
      else
        if rendering.has_content?
          rendering.part.render_with_content(rendering.content,rendering.options.to_hash)
        else
          rendering.part.render(rendering.options.to_hash)
        end
      end
    )
  end

  def render_rendering_filled_with(rendering,inner,opts={})
    content_tag(
      :div,
      inner,
      {:id => dom_id(rendering), :class => "rendering #{rendering.part.andand.filename} #{rendering.content.class.to_s.underscore if rendering.has_content?}"}
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
    add_class_to_html_options(opts, dom_id(grid))
    opts[:id] = dom_id(grid) # unless opts[:id].nil?
    content_tag( :div, inner, opts)
  end

  def render_grid_in_page(thegrid,thepage, opts = {})
    render_grid_filled_with(
      thegrid,
      if thegrid.visible_children.empty?
        renderings = thepage.renderings.for_grid(thegrid)
        if renderings.empty? && current_user.andand.is_admin?
          [
            content_tag(:div,
              content_tag(:span, "Grid #{thegrid.id}: #{thegrid.label}  ") + 
              link_to_remote('create rendering', 
                {:url => renderings_url(:rendering => {:grid_id => thegrid.id, :page_id => thepage.id}),
                 :loading  => "Toolbox.findOrCreate()",
                 :method => :post
                },
                 :class => 'create rendering create_rendering'
              ) +
              ' ' +
              content_tag('span', 'or drag one here'),
            :class => 'rendering fake')
          ]
        else
          renderings.collect do |rendering|
            # FIXME HACK rendering must know about trailing path, this is in da page
            rendering.page = thepage
            rendering.render 
          end
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
    layout = thepage.final_layout
    content_tag(
      :div,
      render(:partial => '/public/header', :object => thepage) + 
      (layout.andand.render_in_page(thepage) || page_without_layout_warning(thepage)) +
      render(:partial => '/public/footer', :object => thepage),
      {:id => thepage.yui, :class => "page #{dom_id(thepage)}"}
    )
  end

  def page_without_layout_warning(thepage)
    content_tag(:div,
                'Page has no Layout ' + link_to("create layout", new_page_layout_path(thepage), :class => 'create layout with_toolbox'),
               :class => 'warning')
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
