class PartsController < ApplicationController
  feeds_toolbox_with :part
  layout 'admin'

  def index
    Part.sync!
    @models = @parts = Part.search(params[:search].andand[:term]).paginate(:page => params[:page], :per_page => 30)
    render_toolbox_action :index
  end

  def after_update_toolbox_for_updated(page)
    if @context_page
      page.update_renderings @context_page.renderings.with_part(@part)
    end
  end

  def preview
    if @context_page
      Part.without_modification do
        @part = Part.find(params[:id])
        respond_to do |wants|
          wants.js do
            render :update do |page|
              if @part.update_attributes(params[:part])
                rends = @context_page.renderings.with_part(@part)
                rends.each { |r| r.part = @part }
                page.update_renderings rends
              else
                if first_rend = @context_page.renderings.with_part(@part).first
                  page.select_rendering(first_rend).html page.context.error_messages_for(:part, :object => @part)
                else
                  flash[:error] = @part.errors.full_messages
                end
              end
            end
          end
        end
      end
    end
  end
end
