class Rendering::PartController < ApplicationController
  before_filter :fetch_rendering
  before_filter :fetch_part
  def edit
    @part.use_theme = @part.in_theme?
    respond_to do |wants|
      wants.js
    end
  end

  def update
    respond_to do |wants|
      wants.js do
        if @part.update_attributes(params[:part])
          flash[:notice] = 'Part was successfully updated.'
          render :template => '/renderings/show'
        else
          render :action => 'edit'
        end
      end
    end
  end


  private
  def fetch_part
    @part = @rendering.part
  end
end
