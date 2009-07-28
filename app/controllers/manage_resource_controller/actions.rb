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
          update_method = 
          send(action) do
            wants.js do
              render :update do |page|
                controller.send "update_page_on_#{action}", page
              end
            end
            if ResourceController::FAILABLE_ACTIONS.include?(action)
              failure do
                wants.js do
                  render :update do |page|
                    controller.send "update_page_on_failed_#{action}", page
                  end
                end
              end
            end
          end
        end
      end
    end
    def self.included(base)
      base.class_eval do
        extend ClassMethods
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
      else
        page.push_or_refresh( 
          :partial => "/list", :object => collection,
          :title => human_name.pluralize
        )
      end
    end

    def update_page_on_new_action(page)
      page.push_toolbox_content(
        :partial => "/form", :object => build_object,
        :title => "New #{human_name}"
      )
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
      page.push_toolbox_content(
        :partial => "/show", :object => object,
        :title => object.andand.title || "#{human_name} ##{object.id}"
      )
    end

    def update_page_on_failed_show(page)
      page.alert("could not find #{human_name}")
    end

    def update_page_on_edit(page)
      page.push_toolbox_content(
        :partial => "/form", :object => object,
        :title => "Edit #{human_name} ##{object.id}"
      )
    end

    # Update the page on updating the record, rjs builder as argument
    def update_page_on_update(page)
      page.toolbox.pop_and_refresh_last()
    end

    def update_page_on_failed_update(page)
      update_or_show_form_in_toolbox(page)
    end

  end
end
