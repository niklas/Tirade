module PagesHelper
  def render_page(thepage)
    render_grid_in_page(thepage.final_layout,thepage)
  end

  def render_grid_in_page(thegrid,thepage)
    if thegrid.visible_children.empty?
      renderings = thepage.renderings.for_grid(thegrid)
      renderings.collect do |rendering|
        unless rendering.part.nil? || rendering.content.nil?
          render_part_with_content(rendering.part, rendering.content)
        else
          '[no part or content assigned]'
        end
      end
    else
      thegrid.visible_children.collect do |child|
        render_grid_in_page(child,thepage)
      end
    end.join(' ')
  end

  def render_part_with_content(part,content)
    render(:partial => part.absolute_partial_name, :object => content)
  end
end
