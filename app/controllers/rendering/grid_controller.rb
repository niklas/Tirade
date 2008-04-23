class Rendering::GridController < ApplicationController
  before_filter :fetch_rendering
  def edit
    @grid = @rendering.grid
    respond_to do |wants|
      wants.js
    end
  end
end
