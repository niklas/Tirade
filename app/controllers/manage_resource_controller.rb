class ManageResourceController < ResourceController::Base

  helper :interface
  helper :toolbox
  before_filter :set_form_builder, :except => [:index,:show,:destroy]

  def self.inherited(child)
    super
    child.class_eval do

      #helper_method :resource_name
      helper_method :human_name
      helper_method :object
      helper_method :collection
      helper_method :build_object

      # Update search results in last frame of toolbox or just push the list
      index.wants.js do
        render :update do |page|
          if params[:search]
            target = page.toolbox.last.find("div.search_results.#{resource_name.pluralize}")
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



  def human_name
    model_name.humanize
  end


  private
  def update_or_show_form_in_toolbox
    render :update do |page|
      if non_form_submit?
        page.push_toolbox_content(:partial => "/form", :object => object)
      else
        page.update_last_toolbox_frame(:partial => "/form", :object => object)
      end
    end
  end
  def collection
    @collection ||= filtered_collection
  end

  def filtered_collection
    if model.acts_as?(:content)
      end_of_association_chain.
        search(params[:search].andand[:term] || params[:term]).
        paginate(:page => params[:page])
    else
      end_of_association_chain.
        paginate(:page => params[:page])
    end
  end

  def object
    @object ||= object_by_slug_or_not
  end

  def object_by_slug_or_not
    if model.acts_as?(:slugged)
      end_of_association_chain.find_by_slug(params[:id]) || end_of_association_chain.find(params[:id])
    else
      end_of_association_chain.find(params[:id])
    end
  end

  def set_form_builder
    if request.xhr?
      ActionView::Base.default_form_builder = ToolboxFormBuilder
    else
      ActionView::Base.default_form_builder = NormalFormBuilder
    end
  end

  def non_form_submit?
    params[:commit].blank?
  end
  helper_method :non_form_submit?

end
