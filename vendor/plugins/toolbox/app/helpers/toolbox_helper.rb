module ToolboxHelper
  def update_toolbox(opts = {})
    if header = (opts[:header] || opts[:top])
      page[:toolbox_top].replace_html header
    end

    page[:toolbox_content].replace_html opts[:content] if opts[:content]
    
    if footer = (opts[:footer] || opts[:bottom] || page.context.flash[:notice])
      page[:toolbox_bottom].replace_html footer
    end
    if nav_name = opts[:nav]
      page[:toolbox_sidebar].replace_html tabnav_to_s(nav_name)
    else
      page[:toolbox_sidebar].replace_html tabnav_to_s('main')
    end
  end

  def push_toolbox_content(content)
    if content.is_a? Hash
      title = content.delete(:title)
      content = render(content)
    else
      title = "#{context.controller.action_name} #{context.controller.controller_name}"
    end
    page.toolbox.push_content content, :href => context.request.url, :title => title
  end

  def update_last_toolbox_frame(content)
    if content.is_a? Hash
      if title = content.delete(:title)
        page.toolbox.set_title title
      end
      content = render(content) 
    end
    page.toolbox.update_last_frame content
  end

  def tabnav_to_s(name)
    partial_name = "widgets/#{name}_tabnav"
    render :partial => partial_name
  end

  def close_toolbox
    page.select('#toolbox').each {|tb| tb.remove }
  end

end
