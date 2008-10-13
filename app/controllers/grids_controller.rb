class GridsController < ApplicationController
  before_filter :login_required
  before_filter :fetch_associated_rendering, :only => [:edit, :update]
  feeds_toolbox_with :grid
  
  # FIXME (must be done in ressourcefull_views plugin)
  protect_from_forgery :except => [:destroy,:order_renderings]

  # TODO create: assign the new grid to params[:page_id]'s Page

  def create_child
    @grid = Grid.find(params[:id])
    @grid.add_child
    respond_to do |wants|
      wants.js { render :action => 'show' }
    end
  end

  def order_renderings
    Rendering.transaction do
      @grid = Grid.find(params[:id])
      renderings_ids = params[:renderings].reject(&:blank?)
      renderings_ids.andand.each_with_index do |r,i|
        rendering = Rendering.find(r)
        rendering.position = i+1
        rendering.grid = @grid
        rendering.save!
      end
      @rendering = Rendering.find(renderings_ids.first)
    end
    respond_to do |wants|
      wants.js { render :template => '/rendering/grid/show' }
    end
  end

  private
  def fetch_associated_rendering
    if rid = params[:rendering_id] || params[:grid].andand[:rendering_id]
      @rendering = Rendering.find_by_id(rid)
    end
    true
  end
end
