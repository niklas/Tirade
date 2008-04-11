module GridHelper
  def render_grid(grid)
    if grid.children.empty?
      inner = h(grid.to_s)
    else
      inner = grid.children.collect {|child| render_grid(child)}.join(' ')
    end
    content_tag(:div, inner, {:class => grid.grid_class})
  end
end
