module GridsHelper
  def show_grid(grid)
    render_grid(grid, :class => 'preview') do |g|
      content_tag(:span, g.label, :class => 'label')
    end
  end
end
