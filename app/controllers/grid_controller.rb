class GridController < ApplicationController

  def show
    @grid = Grid.find(params[:id])
  end
end
