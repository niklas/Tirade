class PublicController < ApplicationController

  def index
    @path = params[:path]
    if @path.andand.last =~ /^(\d+)$/
      # FIXME this item_id gets not recognized in parts, using PublicHelper#dangling_id for now
      @item_id = $1.to_i
      @path = @path[0...-1]
    end
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
