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

  def push_or_refresh(content)
    if context.params[:refresh].blank?
      push_toolbox_content(content)
    else
      refresh_toolbox_content(content)
    end
  end

  def push_toolbox_content(content)
    title, content = prepare_content(content)
    page.toolbox.push content, :href => context.request.url, :title => title
  end

  def refresh_toolbox_content(content)
    title, content = prepare_content(content)
    page.toolbox.update_frame_by_href context.request.url, content, :title => title
  end

  def update_last_toolbox_frame(content)
    title, content = prepare_content(content)
    page.toolbox.set_title title if title
    page.toolbox.update_last_frame content
  end

  def tabnav_to_s(name)
    partial_name = "widgets/#{name}_tabnav"
    render :partial => partial_name
  end

  def close_toolbox
    page.select('#toolbox').each {|tb| tb.remove }
  end

  private
  def prepare_content(content)
    if content.is_a? Hash
      if part = content[:partial] && part.is_a?(String)
        content[:partial] = "/#{@model.table_name}/#{part}"
        content[:object] ||= @model || @models
      end
      [content.delete(:title), render(content)]
    else
      ["#{context.controller.action_name} #{context.controller.controller_name}", content]
    end
  end


end
