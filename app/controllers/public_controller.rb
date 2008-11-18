class PublicController < ApplicationController
  skip_before_filter :check_permissions

  def index
    if @full_path = params[:path]
      @page_path = @full_path.dup
      @trailing_path = []
      while @page.nil? && !@page_path.empty?
        unless @page = Page.find_by_path(@page_path)
          @trailing_path.unshift @page_path.pop
        end
      end
    else
      @page ||= Page.root
      @trailing_path = []
      @page_path = []
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
    respond_to do |wants|
      wants.html { render :action => 'page_not_found' }
      wants.js   { render :action => 'page_not_found' }
    end
  end
end
