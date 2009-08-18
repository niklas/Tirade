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
              render :update do |page|
                controller.send "update_page_on_#{action}", page
                controller.render_flash_messages_as_notifications(page)
              end
            end
            if ResourceController::FAILABLE_ACTIONS.include?(action)
              failure do
                wants.js do
                  render :update do |page|
                    controller.send "update_page_on_failed_#{action}", page
                    controller.render_flash_messages_as_notifications(page)
                  end
                end
              end
            end
          end
        end
        hide_action :update_page_on_preview
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
          object.attributes = object_params
          respond_to do |wants|
            wants.js do
              render :update do |page|
                controller.update_page_on_preview(page)
              end
            end
          end
        end
      end
    end
      
    private
      # Update search results in last frame of toolbox or just push the list
    def update_page_on_index(page)
      if params[:search]
        target = page.toolbox.last.find("div.search_results.#{model_name.pluralize}")
        if collection.empty?
          target.html("No #{resource_name.pluralize.humanize} found.")
        else
          target.html(page.context.list_of(collection, :force_list => true))
        end
      else
        page.push_or_refresh( 
          :partial => "/list", :object => collection,
          :title => human_name.pluralize
        )
      end
    end

    def update_page_on_new_action(page)
      page.push_toolbox_partial('/form', build_object, :title => "New #{human_name}")
    end

    def update_page_on_create(page)
      page.update_last_toolbox_frame(   # replace the form with /show
        :partial => "/show", :object => object,
        :title => "#{human_name} ##{object.id}"
      )
    end

    def update_page_on_failed_create(page)
      update_or_show_form_in_toolbox(page)
    end

    def update_page_on_show(page)
      page.push_toolbox_partial('/show', object)
    end

    def update_page_on_failed_show(page)
      page.alert("could not find #{human_name}")
    end

    def update_page_on_edit(page)
      page.push_toolbox_partial('/form', object, :title => "Edit #{human_name}")
    end

    # Update the page on updating the record, rjs builder as argument
    def update_page_on_update(page)
      page.toolbox.pop_and_refresh_last()
    end

    def update_page_on_failed_update(page)
      update_or_show_form_in_toolbox(page)
    end

    def update_page_on_preview(page)
    end
  end
end
