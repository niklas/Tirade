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
    def update_or_show_form_in_toolbox(page)
      if non_form_submit?
        page.push_frame_for(object, 'form')
      else
        page.update_frame_for(object, 'form')
      end
    end

    def set_form_builder
      respond_to do |wants|
        wants.js { ActionView::Base.default_form_builder = ToolboxFormBuilder }
        wants.json { ActionView::Base.default_form_builder = ToolboxFormBuilder }
        wants.html { ActionView::Base.default_form_builder = NormalFormBuilder }
      end
    end

    def non_form_submit?
      params[:commit].blank?
    end

    # Is any given param not a string.
    def multipart_form?
      object_params.andand.values.andand.any? {|d| d.is_a?(File)}
    end

    def wants_refresh?
      !params[:refresh].blank?
    end

    def set_context_page
      context_page
      true
    end

    def context_page
      return @context_page if @context_page
      logger.debug("setting context page. header: #{request.headers['Tirade-Page']} ")
      if page_id = (request.headers['Tirade-Page'] || params[:context_page_id].andand.to_i)
        @context_page = Page.find_by_id(page_id)
      end
    end

  end
end
