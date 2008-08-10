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

  def append_toolbox_frame(frame_content)
    frame_content = render(frame_content) if frame_content.is_a? Hash
    page.insert_html :bottom, :scroller, context.content_tag(:div,frame_content,:class => 'frame')
    page.toolbox.push
  end

  def tabnav_to_s(name)
    partial_name = "widgets/#{name}_tabnav"
    render :partial => partial_name
  end

  def close_toolbox
    page.select('#toolbox').each {|tb| tb.remove }
  end

  def toolbox_back_button(label='back')
    link_to(label,'#', :class => 'back')
  end

end
