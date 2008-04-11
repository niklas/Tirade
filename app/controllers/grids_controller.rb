class GridsController < ApplicationController

  def show
    @grid = Grid.find(params[:id])
  end
end
