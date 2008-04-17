module GridsHelper
  # Renders the given grid and all its containing grids (and later parts)
  # warning: recursive
  def render_grid(grid,opts = {})
    if grid.children.empty?
      inner = h(grid.inspect.to_s)
    else
      inner = grid.visible_children.collect do |child| 
        render_grid(child)
      end.join(' ')
    end
    content_tag(
      :div, 
      inner, 
      {:class => grid.yuies, :id => dom_id(grid)}
    )
  end
end
