module ManageResourceController
  module Actions
    def setup_actions
      # Update search results in last frame of toolbox or just push the list
      index.wants.js do
        render :update do |page|
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
      end

      new_action.wants.js do
        render :update do |page|
          page.push_toolbox_content(
            :partial => "/form", :object => build_object,
            :title => "New #{human_name}"
          )
        end
      end

      create.wants.js do
        flash[:notice] = "#{human_name} successfully created!"
        render :update do |page|
          page.update_last_toolbox_frame(   # replace the form with /show
            :partial => "/show", :object => object,
            :title => "#{human_name} ##{object.id}"
          )
        end
      end
      create.failure.wants.js do
        flash[:error] = "Failed to create #{human_name}"
        update_or_show_form_in_toolbox
      end


      show.wants.js do
        render :update do |page|
          page.push_toolbox_content(
            :partial => "/show", :object => object,
            :title => object.andand.title || "#{human_name} ##{object.id}"
          )
        end
      end

      edit.wants.js do
        render :update do |page|
          page.push_toolbox_content(
            :partial => "/form", :object => object,
            :title => "Edit #{human_name} ##{object.id}"
          )
        end
      end

      update.wants.js do
        flash[:notice] = "#{human_name} successfully updated!"
        render :update do |page|
          page.toolbox.pop_and_refresh_last()
        end

      end

      update.failure.wants.js do
        flash[:error] = "Failed to update #{human_name}"
        update_or_show_form_in_toolbox
      end
    end
  end
end
