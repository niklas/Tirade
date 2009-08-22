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
    if record.respond_to?(:resource_name)
      add_class_to_html_options opts, 'new' if record.new_record?
      add_class_to_html_options opts, dom_id(record)
      add_class_to_html_options opts, record.resource_name
    end
    inner = frame_content_for(record, partial)
    inner << frame_metainfo_for(record)
    content_tag(:div, inner, opts)
  end

  def frame_for_collection(collection, opts={})
    partial = 'list'
    add_class_to_html_options opts, 'frame'
    add_class_to_html_options opts, 'index'
    add_class_to_html_options opts, collection.first.resource_name unless collection.empty?
    add_class_to_html_options opts, partial
    inner = frame_content_for_collection(collection, partial)
    inner << frame_metadata_for_collection(collection)
    content_tag(:div, inner, opts)
  end

  def frame_content_for_collection(collection, partial='list', opts={})
    opts.reverse_merge!({
      :layout => '/layouts/toolbox',
      :partial => "/#{partial}",
      :object => collection,
      :locals => collection ? {
        resource_name.pluralize.to_sym => collection
      } : nil
    })
    render opts
  end

  def frame_content_for(record, partial='show', opts={})
    opts.reverse_merge!({
      :layout => '/layouts/toolbox',
      :partial => "/#{partial}",
      :object => record,
      :locals => record ? {
        resource_name.to_sym => record
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
      :resource_name => resource_name,
      :id => record.id
    })
    metadata(meta)
  end

  def frame_metadata_for_collection(collection, meta={})
    meta.reverse_merge!({
      :href => request.url, 
      :title => human_name.pluralize,
      :action => controller.action_name, 
      :controller => controller.controller_name,
      :resource_name => resource_name
    })
    metadata(meta)
  end

  def push_frame_for(object,partial=nil, opts={})
    if object.respond_to?(:each)
      page.toolbox.push context.frame_for_collection(object, opts)
    else
      page.toolbox.push context.frame_for(object, partial, opts)
    end
  end

  def update_frame_for(object, partial='show', opts={})
    page.select_frame_for(object, partial).html context.frame_content_for(object, partial, opts)
  end

  def push_toolbox_error(exception)
    page.toolbox.push context.frame_for_error(exception)
  end

  def frame_for_error(exception)
    title = case exception
            when ActionView::TemplateError
              <<-EOTITLE 
                #{exception.original_exception.class.name} in
                #{request.parameters["controller"].andand.capitalize}
                ##{request.parameters["action"]}
              EOTITLE
            else
              exception.class.name
            end
    partial = ApplicationController.rescue_templates[exception.class.name]
    inner = render(
      :partial => "/toolbox/#{partial}",
      :layout => '/layouts/toolbox',
      :object => exception
    )
    content_tag(:div, inner, :class => 'frame error')
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
