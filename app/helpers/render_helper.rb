# The RenderHelper should contain all the helpers to render Pages, Grids, Randerings and Parts
module RenderHelper
  def render_rendering(rendering)
    content_tag(
      :div,
      rendering.part.render_with_content(rendering.content),
      {:id => dom_id(rendering), :class => "rendering #{rendering.part.filename} #{rendering.content.class.to_s.underscore}"}
    )
  end
end
