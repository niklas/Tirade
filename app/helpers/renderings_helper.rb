module RenderingsHelper

  def update_toolbox(opts = {})
    page[:toolbox_header].replace_html opts[:header] if opts[:header]
    page[:toolbox_content].replace_html opts[:content] if opts[:content]
    if footer = (opts[:footer] || page.context.flash[:notice])
      page[:toolbox_footer].replace_html footer
    end
    if nav_name = opts[:nav]
      page[:toolbox_sidebar].replace_html tabnav_to_s(nav_name)
    else
      page[:toolbox_sidebar].replace_html tabnav_to_s('main')
    end
  end

  def tabnav_to_s(name)
    partial_name = "widgets/#{name}_tabnav"
    render :partial => partial_name
  end

  def close_toolbox
    page.select('#toolbox').each {|tb| tb.remove }
  end
  def update_rendering(rendering)
    dom = page.context.dom_id(rendering)
    page[dom].replace rendering.render
    page[dom].reset_behavior
  end

  def update_grid_for(rendering)
    grid = rendering.grid
    grid_dom = page.context.dom_id(grid)
    page[grid_dom].replace page.context.render_grid_in_page(grid,rendering.page)
    page[grid_dom].reset_behavior
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
    page[dom].add_class_name 'active'
  end
  def mark_rendering_as_active(rendering)
    dom = page.context.dom_id(rendering)
    page[dom].add_class_name 'active'
  end
  def unmark_all_active
    page.select('div.active').each do |elem|
      elem.remove_class_name 'active'
      elem.reset_behavior
    end
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
