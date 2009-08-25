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

  def frame_for(thingy, partial='show', opts={})
    FrameRenderer.for(thingy, partial, self, opts).to_s
  end

  def frame_content_for(thingy, partial='show', opts={})
    FrameRenderer.for(thingy, partial, self, opts).inner
  end


  def push_frame_for(thingy,partial=nil, opts={})
    page.toolbox.push context.frame_for(thingy, partial, opts)
  end

  def update_frame_for(object, partial='show', opts={})
    page.select_frame_for(object, partial).html context.frame_content_for(object, partial, opts)
  end

  def push_toolbox_error(exception)
    page.toolbox.push context.frame_for_error(exception)
  end

  def frame_for_error(exception)
    ExceptionFrameRenderer.new(exception, nil, self).to_s
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


end
