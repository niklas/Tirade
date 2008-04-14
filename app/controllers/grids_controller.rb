class GridsController < ApplicationController
  authentication_required

  def show
    @grid = Grid.find(params[:id])
    respond_to do |wants|
      wants.html
      wants.js
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
end
