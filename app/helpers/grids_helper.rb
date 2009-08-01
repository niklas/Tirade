module GridsHelper
  def select_grid(grid, tail='')
    did = page.context.dom_id(grid)
    page.select("div.page div.grid.#{did} #{tail}")
  end

  def update_grid_in_page(grid, thepage)
    if grid.root?
      page.select_grid(grid).
        replace_with(page.context.render_grid_in_page(grid,thepage))
    else
      page.select_grid(grid).parent.
        replace_with(page.context.render_grid_in_page(grid,thepage))
    end
  end

  def show_grid(grid, opts={})
    add_class_to_html_options(opts, 'preview')
    render_grid(grid, opts) do |g|
      content_tag(:span, g.label, :class => "label")
    end
  end
end
