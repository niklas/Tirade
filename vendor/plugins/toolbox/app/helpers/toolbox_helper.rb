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
    if context.params[:refresh].blank? && context.params[:commit].blank?
      push_toolbox_content(content)
    else
      refresh_toolbox_content(content)
    end
  end

  def push_or_refresh_last(content)
    if context.params[:refresh].blank? && context.params[:commit].blank?
      push_toolbox_content(content)
    else
      update_last_toolbox_frame(content)
    end
  end

  def push_toolbox_content(content)
    title, content = prepare_content(content)
    page.toolbox.push content, :href => clean_url, :title => title
    set_toolbox_status
  end

  def refresh_toolbox_content(content)
    title, content = prepare_content(content)
    page.toolbox.frame_by_href(clean_url).update :content => content, :title => title
    set_toolbox_status
  end

  def update_last_toolbox_frame(content)
    title, content = prepare_content(content)
    page.toolbox.update_last_frame content, :title => title
    set_toolbox_status
  end

  def toolbox_error(exception)
    title, content = prepare_content(:title => exception.class.to_s, :partial => '/toolbox/error', :object => exception)
    page.toolbox.error content, :title => title
    set_toolbox_status
  end

  def tabnav_to_s(name)
    partial_name = "widgets/#{name}_tabnav"
    render :partial => partial_name
  end

  def close_toolbox
    page.select('#toolbox').each {|tb| tb.remove }
  end
  def set_toolbox_status
    page.toolbox.set_status(
      if notice = page.context.flash[:notice]
        notice
      elsif error = page.context.flash[:error]
        error
      else
        "Done"
      end
    )
  end

  private

  def clean_url
    context.request.path # url.sub(/_=\d+/,'').sub(/\?$/,'')
  end
  def prepare_content(content)
    if content.is_a? Hash
      if part = content[:partial] && part.is_a?(String)
        content[:partial] = "/#{@model.table_name}/#{part}"
        content[:object] ||= @model || @models
      end
      content[:layout] ||= '/layouts/toolbox'
      [content.delete(:title), render(content)]
    else
      ["#{context.controller.action_name} #{context.controller.controller_name}", content]
    end
  end


end
