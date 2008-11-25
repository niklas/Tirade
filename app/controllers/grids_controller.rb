class GridsController < ApplicationController
  before_filter :login_required
  #before_filter :fetch_associated_rendering, :only => [:edit, :update]
  feeds_toolbox_with :grid
  
  # FIXME (must be done in ressourcefull_views plugin)
  protect_from_forgery :except => [:destroy,:order_renderings, :order_children]

  # TODO create: assign the new grid to params[:page_id]'s Page

  def create_child
    @grid = Grid.find(params[:id])
    @grid.add_child
    refresh
  end

  def order_renderings
    Rendering.transaction do
      @grid = Grid.find(params[:id])
      renderings_ids = params[:rendering].reject(&:blank?)
      renderings_ids.andand.each_with_index do |r,i|
        rendering = Rendering.find(r)
        rendering.position = i+1
        rendering.grid = @grid
        rendering.save!
      end
    end unless params[:rendering].blank?
    refresh
  end

  def order_children
    Grid.transaction do
      @grid = Grid.find(params[:id])
      params[:grid].reject(&:blank?).andand.reverse.each_with_index do |gid,i|
        Grid.find(gid).move_to_child_of @grid
      end
    end unless params[:grid].blank?
    refresh
  end

  private
  def refresh(grid=@grid)
    respond_to do |wants|
      wants.js do
        render :update do |page|
          dom = page.select_grid(grid)
          if thepage = Page.find_by_id(params[:context_page_id])
            dom.replace_with render_grid_in_page(grid, thepage)
          end
          dom.highlight
        end
      end
    end
  end
end
