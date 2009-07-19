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
    title = case exception
            when ActionView::TemplateError
              <<-EOTITLE 
                #{exception.original_exception.class.name} in
                #{page.context.request.parameters["controller"].capitalize if page.context.request.parameters["controller"]}
                ##{page.context.request.parameters["action"]}
              EOTITLE
            else
              exception.class.name
            end
    partial = ApplicationController.rescue_templates[exception.class.name]
    title, content = prepare_content(:title => title, :partial => "/toolbox/#{partial}", :object => exception)
    page.toolbox.error content, :title => title
    set_toolbox_status
  end

  # Update a single attribute with jquery.
  #
  # Example:
  # Giving a Document and :pictures, there 
  # should be searched for a 'div.frame:last div.document ul.pictures' and replaced by a new version (or new li`s)
  # 
  # Document, :title => 'div.document span.title'
  # Story, :body => 'div.story div.body'
  def toolbox_update_model_attribute model, meth
    # TODO something fancy here, mabye reuse the #show calls somehow (they are not called here..)
  end

  def tabnav_to_s(name)
    partial_name = "widgets/#{name}_tabnav"
    render :partial => partial_name
  end

  def close_toolbox
    page.select('#toolbox').remove
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

  # FIXME obsolte, use #object and #collection from resource_controller
  # returns the active model you set in your controller (@article)
  def model
    (@model ||= instance_variable_get("@#{controller.controller_name.singularize}")) || 
      raise("no #{controller.controller_name.singularize} loaded")
  end
  # returns the active list of models you set in your controller (@articles)
  def models
    (@models ||= instance_variable_get("@#{controller.controller_name}")) || raise("no #{controller.controller_name} loaded")
  end

  private

  def clean_url
    context.request.path # url.sub(/_=\d+/,'').sub(/\?$/,'')
  end
  def prepare_content(content)
    returning [] do |ary|
      if content.is_a? Hash
        content[:layout] ||= '/layouts/toolbox'
        content[:object] ||= object || collection
        ary << content.delete(:title) || content[:object].andand.title || 'Foo Title'
        begin
          result = render(content)
          ary << result
        rescue ActionView::MissingTemplate => e  # try to add the table name to the partial path
          if content[:partial] && content[:object] && content[:partial] !~ %r~./~ 
            content[:partial] = "/#{content[:object].table_name}/#{content[:partial]}"
            retry
          else
            raise e
          end
        end
      else
        ary << "#{context.controller.action_name} #{context.controller.controller_name}"
        ary << content
      end
    end
  end


end
