class PublicController < ApplicationController

  def index
    @path = params[:path]
    @item_id = @path.andand.last =~ /^\d+$/ ? @path.pop : nil
    unless (@page_url = @path.andand.collect(&:downcase).andand.join('/') || '').blank?
      @page = Page.find_by_url(@page_url)
    else
      @page = Page.root
    end
    store_location
  end
end
