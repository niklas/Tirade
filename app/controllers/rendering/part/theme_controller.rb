class Rendering::Part::ThemeController < ApplicationController
  before_filter :fetch_rendering
  before_filter :fetch_part
  def create
    @part.make_themable!
    continue_editing
  end
  def update
    @part.use_theme = params[:use_theme]
    continue_editing
  end
  def destroy
    @part.make_unthemable!
    continue_editing
  end
  private
  def continue_editing
    respond_to do |wants|
      wants.js { render :template => 'rendering/part/edit'}
    end
  end
  def fetch_part
    @part = @rendering.part
  end
end
