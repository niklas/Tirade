module ManageResourceController
  module Helpers

    def self.included(base)
      base.class_eval do
        before_filter :set_form_builder, :except => [:index,:show,:destroy]
        before_filter :set_context_page
        helper_method :non_form_submit?
      end
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
  end
end
