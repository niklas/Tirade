module ManageResourceController
  class Base < ResourceController::Base

    helper :interface
    helper :toolbox
    helper_method :resource_name
    helper_method :human_name
    helper_method :object
    helper_method :collection
    helper_method :build_object

    hide_action :resource_name, :human_name, :belongs_to, :route_name, :object_name

    include ManageResourceController::Clipboard
    include ManageResourceController::Helpers
    include  ManageResourceController::Actions
    include Lockdown::Session

    rescue_from 'ActionView::TemplateError', :with => :rescue_error
    rescue_from 'ActionView::MissingTemplate', :with => :rescue_error


    def self.inherited(child)
      super
      child.setup_actions
    end

    private
    def human_name
      model_name.humanize
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
  end
end
