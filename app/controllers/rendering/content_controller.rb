class Rendering::ContentController < ApplicationController
  before_filter :fetch_rendering
  before_filter :fetch_content
  def edit
    respond_to do |wants|
      wants.js
    end
  end

  def preview
    @content.attributes = params[:content]
    respond_to do |wants|
      wants.js
    end
  end

  private
  def fetch_content
    @content = @rendering.content
  end
end
