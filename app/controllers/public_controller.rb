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
    unless @page
      page_not_found
      return
    end

    respond_to do |wants|
      wants.html
      wants.js
    end
  end

  def page_not_found
    render :action => 'page_not_found'
  end
end
