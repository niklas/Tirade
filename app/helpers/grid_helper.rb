module GridHelper
  def render_grid(grid)
    content_tag(:div, h(grid.to_s), {:class => grid.grid_class})
  end
end
