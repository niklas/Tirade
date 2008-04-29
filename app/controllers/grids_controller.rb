class GridsController < ApplicationController
  before_filter :login_required
  
  # FIXME (must be done in ressourcefull_views plugin)
  protect_from_forgery :except => [:destroy,:order_renderings]

  def show
    @grid = Grid.find(params[:id])
    respond_to do |wants|
      wants.html
      wants.js
    end
  end

  def create_child
    @grid = Grid.find(params[:id])
    @grid.add_child
    respond_to do |wants|
      wants.js { render :action => 'show' }
    end
  end

  def edit
    @grid = Grid.find(params[:id])
    respond_to do |wants|
      wants.js do
        if (rid = params[:rendering_id]) && (@rendering = Rendering.find_by_id(rid))
          @grid.rendering_id = rid
          render :template => '/rendering/grid/edit'
        else
          render
        end
      end
    end
  end

  def update
    @grid = Grid.find(params[:id])
    respond_to do |wants|
      wants.js do
        @rendering = (rid = params[:grid][:rendering_id]) ? Rendering.find_by_id(rid) : nil
        if @grid.update_attributes(params[:grid])
          if @rendering
            render :template => '/rendering/grid/show'
          else
            render :action => 'show'
          end
        else
          if @rendering
            render :template => '/rendering/grid/edit'
          else
            render :action => 'edit'
          end
        end
      end
    end
  end

  def destroy
    @grid = Grid.find(params[:id])
    parent = @grid.parent
    respond_to do |wants|
      if @grid.destroy
        @grid = parent.reload
        wants.js { render :action => 'show' }
      else
        wants.js { render :action => 'edit' }
      end
    end
  end

  def order_renderings
    Rendering.transaction do
      @grid = Grid.find(params[:id])
      renderings_ids = params[:renderings]
      renderings_ids.andand.each_with_index do |r,i|
        rendering = Rendering.find(r)
        rendering.position = i+1
        rendering.save!
      end
      @rendering = Rendering.find(renderings_ids.first)
    end
    respond_to do |wants|
      wants.js { render :template => '/rendering/grid/show' }
    end
  end
end
