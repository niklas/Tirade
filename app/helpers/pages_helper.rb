module PagesHelper

  def render_part_with_content_for_rendering(rendering)
    content_tag(
      :div,
      rendering_contents(rendering),
      {:id => dom_id(rendering), :class => 'rendering'}
    )
  end

  # FIXME what is that doing here?
  # just renders the rendering
  def rendering_contents(rendering)
    raise "depricated?"
    render(
      :partial => rendering.part.absolute_partial_name, 
      :object  => rendering.content, 
      :locals => rendering.final_options
    )
  end
end
