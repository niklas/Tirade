module PagesHelper
  def render_page(thepage)
    content_tag(
      :div,
      render_grid_in_page(thepage.final_layout,thepage),
      {:id => thepage.yui}
    )
  end

  def render_grid_in_page(thegrid,thepage)
    render_grid_filled_with(
      thegrid,
      if thegrid.visible_children.empty?
        renderings = thepage.renderings.for_grid(thegrid)
        renderings.collect do |rendering|
          unless rendering.part.nil? || rendering.content.nil?
            render_part_with_content_for_rendering(rendering)
          else
            '[no part or content assigned]'
          end
        end
      else
        thegrid.visible_children.collect do |child|
          render_grid_in_page(child,thepage)
        end
      end.join(' ')
    )
  end

  def render_part_with_content_for_rendering(rendering)
    render(
      :partial => rendering.part.absolute_partial_name, 
      :object  => rendering.content, 
      :locals => rendering.options.merge(rendering.part.options)
    )
  end
end
