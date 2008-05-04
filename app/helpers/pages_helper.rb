module PagesHelper
  def render_page(thepage)
    layout = thepage.final_layout
    content_tag(
      :div,
      render(:partial => '/public/header', :object => thepage) + 
      (layout ? render_grid_in_page(layout,thepage) : 'Page has no Layout') +
      render(:partial => '/public/footer', :object => thepage),
      {:id => thepage.yui}
    )
  end

  def render_part_with_content_for_rendering(rendering)
    content_tag(
      :div,
      rendering_contents(rendering),
      {:id => dom_id(rendering), :class => 'rendering'}
    )
  end

  # just renders the rendering
  def rendering_contents(rendering)
    render(
      :partial => rendering.part.absolute_partial_name, 
      :object  => rendering.content, 
      :locals => rendering.final_options
    )
  end
end
