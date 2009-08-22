module ToolboxHelper
  include UtilityHelper
  include RjsHelper

  def update_toolbox(opts = {})
    raise "deprecated?"
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

  # Select a frame by controller and action
  def select_frame(contr, act='index')
    page.toolbox.frames(":resource(#{contr}/#{act})")
  end

  def select_frame_for(record, action='show')
    page.toolbox.frames(".#{action}.#{context.dom_id(record)}")
  end

  def frame_for(record, partial='show', opts={})
    add_class_to_html_options opts, 'frame'
    add_class_to_html_options opts, partial
    add_class_to_html_options opts, 'edit' if partial=='form'
    add_class_to_html_options opts, 'new' if record.new_record?
    add_class_to_html_options opts, dom_id(record)
    add_class_to_html_options opts, record.resource_name
    inner = frame_content_for(record, partial)
    inner << frame_metainfo_for(record)
    content_tag(:div, inner, opts)
  end

  def frame_content_for(record, partial='show', opts={})
    opts.reverse_merge!({
      :layout => '/layouts/toolbox',
      :partial => "/#{partial}",
      :object => record,
      :locals => record ? {
        record.controller_name.singularize.to_sym => record
      } : nil
    })
    begin
      render(opts)
    rescue ActionView::MissingTemplate => e
      # try to add the table name to the partial path
      if opts[:partial] !~ %r~./~
        opts[:partial] = "/#{record.table_name}/#{partial}"
        retry
      else
        raise e
      end
    end
  end

  def frame_metainfo_for(record, meta={})
    meta.reverse_merge!({
      :href => request.url, 
      :title => record.title || "#{record.class_name} ##{record.id}", 
      :action => controller.action_name, 
      :controller => controller.controller_name,
      :resource_name => record.resource_name,
      :id => record.id
    })
    metadata(meta)
  end

  def push_frame_for(object,partial='show', opts={})
    page.toolbox.push context.frame_for(object, partial, opts)
  end

  def update_frame_for(object, partial='show', opts={})
    page.select_frame_for(object, partial).html context.frame_content_for(object, partial, opts)
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

  def push_toolbox_partial(partial, thingy=nil, options={})
    options.reverse_merge!({
      :partial => partial.starts_with?('/') ?  partial : "/#{partial}",
      :title => thingy ? (thingy.title || "#{context.human_name} ##{thingy.id}") : context.human_name.pluralize,
      :object => thingy,
      :locals => thingy ? {
        thingy.table_name.singularize.to_sym => thingy
      } : nil
    })
    push_toolbox_content(options)
  end

  def push_toolbox_content(content)
    id = if content[:object].andand.is_a?(ActiveRecord::Base)
           content[:object].id
         else
           nil
         end
    title, content = context.prepare_content(content)
    page.toolbox.push content, 
      :href => context.clean_url, 
      :title => title, 
      :action => context.controller.action_name, 
      :controller => context.controller.controller_name,
      :resource_name => context.controller.model_name,
      :id => id
    set_toolbox_status
  end

  def refresh_toolbox_content(content)
    title, content = context.prepare_content(content)
    page.toolbox.frame_by_href(clean_url).update :content => content, :title => title
    set_toolbox_status
  end

  def update_last_toolbox_frame(content)
    title, content = context.prepare_content(content)
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
    title, content = context.prepare_content(:title => title, :partial => "/toolbox/#{partial}", :object => exception)
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

  def prepare_content(content)
    returning [] do |ary|
      if content.is_a? Hash
        content[:layout] ||= '/layouts/toolbox'
        ary << content.delete(:title) || content[:object].andand.title || 'Foo Title'
        begin
          result = render(content)
          ary << result
        rescue ActionView::MissingTemplate => e 
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
