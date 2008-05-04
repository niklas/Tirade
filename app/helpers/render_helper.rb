# The RenderHelper should contain all the helpers to render Pages, Grids, Randerings and Parts
module RenderHelper
  def render_rendering(rendering)
    content_tag(
      :div,
      rendering.part.render_with_content(rendering.content),
      {:id => dom_id(rendering), :class => "rendering #{rendering.part.filename} #{rendering.content.class.to_s.underscore}"}
    )
  end

  # Renders the given grid and all its containing grids
  # warning: recursive
  def render_grid(grid,opts = {})
    if grid.children.empty?
      inner = h(grid.inspect.to_s)
    else
      inner = grid.visible_children.collect do |child| 
        render_grid(child,opts)
      end.join(' ')
    end
    render_grid_filled_with(grid,inner,opts)
  end

  # Renderings just the grid container
  def render_grid_filled_with(grid,inner,opts={})
    content_tag(
      :div, 
      inner, 
      {:class => grid.yuies, :id => dom_id(grid)}
    )
  end

  def render_grid_in_page(thegrid,thepage, opts = {})
    render_grid_filled_with(
      thegrid,
      if thegrid.visible_children.empty?
        renderings = thepage.renderings.for_grid(thegrid)
        renderings.collect do |rendering|
          unless rendering.part.nil? || rendering.content.nil?
            rendering.render 
          else
            '[no part or content assigned]'
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
      thepage.render_to_string(:partial => '/public/header', :object => thepage) + 
      (layout.andand.render_in_page(thepage) || 'Page has no Layout') +
      thepage.render_to_string(:partial => '/public/footer', :object => thepage),
      {:id => thepage.yui}
    )
  end
end
