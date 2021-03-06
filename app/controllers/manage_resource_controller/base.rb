module ManageResourceController
  class Base < ResourceController::Base

    helper :interface
    helper :toolbox
    helper :utility
    helper :rjs
    helper_method :resource_name
    helper_method :human_name
    helper_method :object
    helper_method :collection
    helper_method :build_object
    helper_method :clean_url

    hide_action :resource_name, :human_name, :belongs_to, :route_name, :object_name

    include ManageResourceController::Clipboard
    include ManageResourceController::Helpers
    include ManageResourceController::Actions
    include ManageResourceController::Notifications
    #include Lockdown::Session # do we ever need this _here_?

    rescue_from 'ActionView::TemplateError', :with => :rescue_error
    rescue_from 'ActionView::MissingTemplate', :with => :rescue_error


    def self.inherited(child)
      super
      child.setup_actions
    end

    private
    def clean_url
      request.path # url.sub(/_=\d+/,'').sub(/\?$/,'')
    end

    def human_name
      model_name.humanize
    end

    def resource_name
      model_name
    end

    def collection
      @collection ||= filtered_collection
    end

    def filtered_collection
      if model.acts_as?(:content)
        end_of_association_chain.
          search(params[:search].andand[:term] || params[:term]).
          all
      elsif model < ActiveRecord::Base
        end_of_association_chain.all
      else
        end_of_association_chain.all
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
