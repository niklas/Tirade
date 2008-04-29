module PagesHelper
  def render_page(thepage)
    layout = thepage.final_layout
    content_tag(
      :div,
      render(:partial => '/public/header', :object => thepage) + 
      (layout ? render_grid_in_page(layout,thepage) : 'Page has no Layout'),
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
