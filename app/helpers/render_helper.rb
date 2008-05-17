# The RenderHelper should contain all the helpers to render Pages, Grids, Randerings and Parts
module RenderHelper
  def render_rendering(rendering)
    render_rendering_filled_with(
      rendering,
      unless rendering.part.nil? || rendering.content.nil?
        rendering.part.render_with_content(rendering.content,rendering.options.to_hash)
      else
        content_tag(:div, 'no part or content assigned', {:class => 'warning'})
      end
    )
  end

  def render_rendering_filled_with(rendering,inner,opts={})
    content_tag(
      :div,
      inner,
      {:id => dom_id(rendering), :class => "rendering #{rendering.part.andand.filename} #{rendering.content.andand.class.to_s.underscore}"}
    )
  end

  # Renders the given grid and all its containing grids
  # warning: recursive
  def render_grid(grid,opts = {})
    if grid.children.empty?
      inner = h(grid.inspect.to_s)
    else
      inner = grid.visible_children.collect do |child| 
        render_grid(child,opts)
      end.join(' ')
    end
    render_grid_filled_with(grid,inner,opts)
  end

  # Renderings just the grid container
  def render_grid_filled_with(grid,inner,opts={})
    content_tag(
      :div, 
      inner, 
      {:class => grid.yuies, :id => dom_id(grid)}
    )
  end

  def render_grid_in_page(thegrid,thepage, opts = {})
    render_grid_filled_with(
      thegrid,
      if thegrid.visible_children.empty?
        renderings = thepage.renderings.for_grid(thegrid)
        if renderings.empty? && current_user.is_admin?
          [
            content_tag(:div,
              link_to_remote('create rendering', 
                {:url => renderings_url(:rendering => {:grid_id => thegrid.id, :page_id => thepage.id}),
                 :loading  => "new Toolbox('Toolbox', {'cornerRadius': 4})"},
                 :method => :post) +
                 ' ' +
              content_tag('span', 'or drag one here'),
            :class => 'rendering fake')
          ]
        else
          renderings.collect do |rendering|
            rendering.render 
          end
        end
      else
        thegrid.visible_children.collect do |child|
          render_grid_in_page(child,thepage)
        end
      end.join(' '),
      opts
    )
  end

  def render_page(thepage)
    layout = thepage.final_layout
    layout.andand.active_controller = @controller
    content_tag(
      :div,
      render(:partial => '/public/header', :object => thepage) + 
      (layout.andand.render_in_page(thepage) || 'Page has no Layout') +
      render(:partial => '/public/footer', :object => thepage),
      {:id => thepage.yui}
    )
  end
end
