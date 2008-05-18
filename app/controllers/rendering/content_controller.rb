class Rendering::ContentController < ApplicationController
  protect_from_forgery :except => :new
  before_filter :fetch_rendering
  before_filter :fetch_content
  # Search for all valid content types
  def new
    @term = params[:term]
    @contents = unless @term.blank?
                  Rendering.valid_content_types.inject([]) do |found,klass|
                    found + klass.search(@term)
                  end.flatten.uniq
                else
                  []
                end
    respond_to do |wants|
      wants.js
    end
  end
  def edit
    respond_to do |wants|
      wants.js
    end
  end

  private
  def fetch_content
    @content = @rendering.content if @rendering.has_content?
  end
end
