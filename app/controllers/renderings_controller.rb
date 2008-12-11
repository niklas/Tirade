class RenderingsController < ApplicationController
  protect_from_forgery :only => []
  feeds_toolbox_with :rendering

  def after_update_toolbox_for_created(page)
    page.update_grid_for(@rendering)
    page.unmark_all_active
    page.mark_as_active(@rendering)
  end

  def after_update_toolbox_for_updated(page)
    page.unmark_all_active
    page.update_rendering(@rendering)
    if @rendering.grid_changed?
      page.remove_rendering(@rendering)
      page.update_grid_in_page(@rendering.grid, @rendering.page) 
      page.update_grid_in_page(@rendering.old_grid, @rendering.page) 
    end
    page.mark_as_active(@rendering)
  end

  def after_update_toolbox_for_show(page)
    page.update_rendering(@rendering) 
    @rendering.brothers_by_part.each do |brother|
      page.update_rendering(brother)
    end if params[:part]
    page.unmark_all_active
    #page.mark_as_active(@rendering)
  end

  def destroy
    @rendering.destroy

    respond_to do |format|
      format.html { redirect_to( @rendering.page.nil? ? '/' : public_content_url(:path => @rendering.page.path)) }
      format.xml  { head :ok }
      format.js do
        render :update do |page|
          page.toolbox.close()
          page.update_grid_for(@rendering)
          page.unmark_all_active
        end
      end
    end
  end

  def duplicate
    @original_rendering = Rendering.find(params[:id])
    @model = @rendering = @original_rendering.clone
    if @rendering.save
      render_toolbox_action :created
    else
      render_toolbox_action :failed_create
    end
  end

  def preview
    if @rendering = Rendering.find(params[:id])
      Rendering.without_modification do
        @rendering.attributes = params[:rendering]
        respond_to do |wants|
          wants.js do
            render :update do |page|
              page.update_rendering(@rendering)
            end
          end
        end
      end
    end
  end
end
