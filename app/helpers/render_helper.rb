# The RenderHelper should contain all the helpers to render Pages, Grids, Randerings and Parts
module RenderHelper
  def warning(message)
    content_tag(:div, message, :class => 'warning')
  end

  def render_page(thepage, locals = {})
    render(:partial => 'pages/page', :object => thepage, :locals => locals)
  end

  def render_grid(grid, locals = {})
    locals.reverse_merge! :page => false
    render(:partial => 'grids/grid', :layout => 'grids/wrapper', :object => grid, :locals => locals)
  end

  def render_grid_in_page(grid, page)
    render_grid(grid, :page => page)
  end

  def render_rendering(rendering, locals = {})
    locals.reverse_merge! :page => false, :grid => false
    render(:partial => 'renderings/rendering', :object => rendering, :locals => locals)
  end

  def div_wrap(inner, css, opts={})
    add_class_to_html_options(opts, css)
    content_tag( :div, inner, opts)
  end

  def page_without_layout_warning(thepage)
    content_tag(:div,
                'Page has no Layout, drop one',
                :class => 'warning page_without_layot')
  end

  def remove_page
    page.select('body > div.page_margins').remove
  end

  def clear
    remove_page
    page.select("body > .header, body > .footer, body > .admin, body > .error").remove
  end

  def insert_page(thepage)
    page.select('body').prepend render(:inline => "<%= render_page(thepage) %>" , :locals => {:thepage => thepage})
  end

  def focus_on(record)
    page.focus.on( '.' + context.dom_id(record) )
  end
end
