module GridsHelper
  def show_grid(grid)
    render_grid(grid, :class => 'preview') do |g|
      content_tag(:span, g.label, :class => "label #{'active' if g==@grid }")
    end
  end
end
