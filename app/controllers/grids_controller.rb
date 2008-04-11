class GridsController < ApplicationController
  authentication_required

  def show
    @grid = Grid.find(params[:id])
  end
end
