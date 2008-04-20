module GridsHelper
  # Renders the given grid and all its containing grids (and later parts)
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

  def render_grid_filled_with(grid,inner,opts={})
    content_tag(
      :div, 
      inner, 
      {:class => grid.yuies, :id => dom_id(grid)}
    )
  end
end
