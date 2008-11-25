module RenderingsHelper

  def update_rendering(rendering, opts={})
    page.select_rendering(rendering).replace_with opts[:with] || rendering.render
  end

  def update_renderings(renderings)
    renderings.each do |rendering|
      update_rendering(rendering)
    end
  end

  def select_rendering(rendering)
    did = page.context.dom_id(rendering)
    page.select("div.rendering.#{did}, div##{did}")
  end

  def remove_rendering(rendering)
    select_rendering(rendering).remove
  end

  def update_grid_for(rendering)
    page.update_grid_in_page(rendering.grid, rendering.page).
      highlight unless rendering.grid.nil?
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
    page.select_grid(grid).add_class 'active'
  end
  def mark_rendering_as_active(rendering)
    page.select_rendering(rendering).add_class 'active'
  end
  def unmark_all_active
    page.select('div.active').remove_class 'active'
  end

  def preview_rendering(rendering)
    dom = page.select_rendering(rendering)
    if rendering.part.valid?
      dom.replace_with rendering.render
    else
      dom.html context.error_messages_for(:part, :object => rendering.part)
    end.highlight
  end
end
