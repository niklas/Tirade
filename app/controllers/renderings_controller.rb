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
    page.mark_as_active(@rendering)
  end

  def after_update_toolbox_for_show(page)
    page.update_rendering(@rendering) 
    @rendering.brothers_by_part.each do |brother|
      page.update_rendering(brother)
    end if params[:part]
    page.unmark_all_active
    page.mark_as_active(@rendering)
  end

  def destroy
    @rendering.destroy

    respond_to do |format|
      format.html { redirect_to( @rendering.page.nil? ? '/' : public_content_url(:path => @rendering.page.path)) }
      format.xml  { head :ok }
      format.js do
        render :update do |page|
          page.close_toolbox
          page.update_grid_for(@rendering)
          page.unmark_all_active
        end
      end
    end
  end

  def duplicate
    @original_rendering = Rendering.find(params[:id])
    respond_to do |wants|
        wants.js {
          if (@rendering = @original_rendering.clone) && @rendering.save
            render :action => 'create'
          else
            render :update do |page|
              page.alert @rendering.andand.errors.full_messages
            end
          end
        }
    end
  end

  def preview
    @rendering = Rendering.find(params[:id])
    @rendering.attributes = params[:rendering] if params[:rendering]
    @rendering.part.attributes = params[:part] if params[:part]
    @rendering.grid.attributes = params[:grid] if params[:grid]
    @rendering.content.attributes = params[:content] if params[:content]
    if @rendering.has_content? && @rendering.content.respond_to?(:items)
      @item_id = @rendering.content.items.first.andand.id
    end
    respond_to do |wants|
      wants.js
    end
  end
end
