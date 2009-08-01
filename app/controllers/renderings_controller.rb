class RenderingsController < ManageResourceController::Base
  def update_page_on_show(page)
    super
    page.update_rendering(@rendering) 
    @rendering.brothers_by_part.each do |brother|
      page.update_rendering(brother)
    end if params[:part]
    page.focus_on(@rendering)
  end

  def update_page_on_new_action(page)
    super
    page.select_grid(@rendering.grid, '.warning').remove
    page.select_grid(@rendering.grid, '.new_rendering').remove
    page.select_grid(@rendering.grid).prepend(
      page.render_rendering(@rendering, :page => @rendering.page)
    )
    page.focus_on(@rendering)
  end

  def update_page_on_create(page)
    super
    page.update_grid_for(@rendering)
  end

  def update_page_on_failed_create(page)
    super
    logger.debug(params[:_json].to_yaml)
  end

  def update_page_on_destroy(page)
    super
    page.update_grid_for(@rendering)
    page.focus_on(@rendering.grid)
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
