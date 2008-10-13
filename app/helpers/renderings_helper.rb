module RenderingsHelper

  def update_rendering(rendering)
    dom = page.context.dom_id(rendering)
    page[dom].replace rendering.render
  end

  def update_grid_for(rendering)
    grid = rendering.grid
    grid_dom = page.context.dom_id(grid)
    page[grid_dom].replace page.context.render_grid_in_page(grid,rendering.page)
    page[grid_dom].visual_effect :highlight
  end

  def mark_as_active(thingy)
    case thingy
    when Rendering
      mark_rendering_as_active(thingy)
      mark_grid_as_active(thingy.grid)
    when Grid
      mark_grid_as_active(thingy)
    end
  end

  def mark_grid_as_active(grid)
    dom = page.context.dom_id(grid)
    page[dom].add_class 'active'
  end
  def mark_rendering_as_active(rendering)
    dom = page.context.dom_id(rendering)
    page[dom].add_class 'active'
  end
  def unmark_all_active
    page.select('div.active').remove_class 'active'
  end

  def preview_rendering(rendering)
    dom = context.dom_id(rendering)
    if rendering.part.valid?
      page[dom].replace rendering.render
    else
      page[dom].replace_html context.error_messages_for(:part, :object => rendering.part)
    end
    page[dom].visual_effect :highlight
  end
end
