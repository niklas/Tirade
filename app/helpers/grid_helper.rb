module GridHelper
  # Renders the given grid and all its containing grids (and later parts)
  # warning: recursive
  def render_grid(grid,opts = {})
    if grid.children.empty?
      inner = h(grid.to_s)
      css_class = grid.grid_class
      css_class += ' first' if opts[:is_first]
    else
      inner = grid.children.collect do |child| 
        render_grid(child, :is_first => (child == grid.children.first))
      end.join(' ')
      css_class = grid.grid_class
    end
    content_tag(:div, inner, {:class => css_class})
  end
end
