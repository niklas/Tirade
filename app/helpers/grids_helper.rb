module GridsHelper
  # Renders the given grid and all its containing grids (and later parts)
  # warning: recursive
  def render_grid(grid,opts = {})
    if grid.children.empty?
      inner = h(grid.to_s)
    else
      inner = grid.children.collect do |child| 
        render_grid(child)
      end.join(' ')
    end
    content_tag(
      :div, 
      (current_user.may?(:grid,:edit) ? link_to(_('edit'), edit_grid_path(grid)) : '') + 
      inner, 
      {:class => grid.grid_classes}
    )
  end
end
