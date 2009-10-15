module ManageResourceController
  module Actions
    module ClassMethods
      def setup_actions
        human_name = model_name.humanize
        create.flash "#{human_name} successfully created!"
        update.flash "#{human_name} successfully updated!"
        create.failure.flash "Failed to create #{human_name}."
        update.failure.flash "Failed to update #{human_name}."
        ResourceController::ACTIONS.each do |action|
          hide_action "update_page_on_#{action}"
          hide_action "update_page_on_failed_#{action}"
          send(action) do
            wants.js do
              update_page_in_toolbox do |page|
                self.send "update_page_on_#{action}", page
                self.render_flash_messages_as_notifications(page)
              end
            end
            if ResourceController::FAILABLE_ACTIONS.include?(action)
              failure do
                wants.js do
                  update_page_in_toolbox do |page|
                    self.send "update_page_on_failed_#{action}", page
                    self.render_flash_messages_as_notifications(page)
                  end
                end
              end
            end
          end
        end
        hide_action :update_page_on_preview
        index.wants.xml do
          render :xml => collection
        end
        show.wants.xml do
          render :xml => object
        end
      end
    end
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        before_filter :load_object, :only => [:preview]
      end
    end

    def preview
      if object
        model.without_modification do
          @object.update_attributes object_params
          respond_to do |wants|
            wants.js do
              render :update do |page|
                controller.send :update_page_on_preview, page
              end
            end
          end
        end
      end
    end

    def scopes
      respond_to do |wants|
        wants.json do
          if model.acts_as?(:content)
            @scopes = model.scopes_grouped_by_column
          else
            @scopes = {}
          end
          render :json => @scopes
        end
        wants.html do
          @rendering = Rendering.new(:content_type => model.name, :assignment => 'scope')
          render :partial => '/model/scope_blueprint'
        end
      end
    end

    def move
      if left = params[:left_of]
        object.move_to_left_of(left)
      elsif right = params[:right_of]
        object.move_to_right_of(right)
      end
      respond_to do |wants|
        wants.js do
          render :update do |page|
            controller.send :update_page_on_moved, page
          end
        end
      end
    end
      
    private
    # Handle file uploads through iframe, see jquery.form.js and render_to_parent
    def update_page_in_toolbox
      if  multipart_form?
        responds_to_parent do
          render :update do |page|
            yield page
          end
        end
      else
        render :update do |page|
          yield page
        end
      end
    end
      # Update search results in last frame of toolbox or just push the list
    def update_page_on_index(page)
      if params[:search]
        target = page.toolbox.last.find("div.search_results.#{model_name.pluralize}")
        if collection.empty?
          target.html("No #{resource_name.pluralize.humanize} found.")
        else
          target.html(page.context.list_of(collection, :force_list => true))
        end
      elsif wants_refresh?
        # TODO replace current_frame
        page.update_current_frame(collection)
      else
        page.push_frame_for(collection, index_view)
      end
    end

    def update_page_on_new_action(page)
      page.push_frame_for(build_object, 'form', :title => "New #{human_name}")
    end

    def update_page_on_create(page)
      page.update_current_frame(object, 'show', :action => 'show')
      page.select_frame(resource_name.pluralize, 'index').refresh()
      update_object_parent(page)
      page.toolbox.set_clipboard render(:partial => 'clipboard/index')
    end

    def update_page_on_failed_create(page)
      update_or_show_form_in_toolbox(page)
    end

    # TODO must add :object_name (:as) to partial call => refactor ToolboxHelper
    def update_page_on_show(page)
      if wants_refresh?
        page.update_frame_for(object)
      else
        page.push_frame_for(object)
      end
    end

    def update_page_on_failed_show(page)
      page.alert("could not find #{human_name}")
    end

    def update_page_on_edit(page)
      model.without_modification do
        object.attributes = object_params
        if page.current_frame?
          page.update_current_frame(object, 'form')
        else
          page.push_frame_for(object, 'form')
        end
      end
    end

    def update_page_on_update(page)
      page.select_frame_for(object, 'show').refresh()
      page.select_frame(resource_name.pluralize, 'index').refresh()
      page.update_current_frame(object, 'show', :action => 'show')
      update_object_parent(page)
    end

    def update_page_on_failed_update(page)
      update_or_show_form_in_toolbox(page)
    end

    def update_page_on_preview(page)
      if object.acts_as?(:content) && @context_page
        @context_page.renderings.for_content(object).each do |rendering|
          rendering.content = object
          rendering.touch
          page.update_rendering(rendering)
        end
      end
    end

    def update_page_on_destroy(page)
      page.select_frame_for(object).remove
      page.select_frame(resource_name.pluralize, 'index').refresh()
      update_object_parent(page)
    end

    def update_page_on_moved(page)
      parent = object.parent
      page.select_frame_for(parent, 'edit').find('.sort ul.list').replace_with( page.context.list_of(parent.children, :force_list => true) )
    end

    # name of partial to render on /index
    def index_view
      'list'
    end

    def update_object_parent(page)
      if object.respond_to?(:parent) && parent = object.parent
        page.update_frame_for(parent)
      end
    end
  end
end
