class GridsController < ApplicationController

  # FIXME (must be done in ressourcefull_views plugin)
  protect_from_forgery :except => :destroy

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
      wants.js
    end
  end

  def update
    @grid = Grid.find(params[:id])
    respond_to do |wants|
      if @grid.update_attributes(params[:grid])
        wants.js { render :action => 'show' }
      else
        wants.js { render :action => 'edit' }
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
end
