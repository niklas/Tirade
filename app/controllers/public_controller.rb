class PublicController < ApplicationController

  def index
    @path = params[:path]
    unless (@url = @path.andand.collect(&:downcase).andand.join('/') || '').blank?
      @page = Page.find_by_url(@url)
    else
      @page = Page.root
    end
    store_location
  end
end
