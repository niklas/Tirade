class PublicController < ApplicationController
  skip_before_filter :check_permissions
  skip_before_filter :login_required

  def index
    @trailing_path = []
    @page_path = []
    if @full_path = params[:path]
      if @page = Page.find_by_path(@full_path)
        @trailing_path = @page.trailing_path
        @page_path = @page.path
      else
        @trailing_path = params[:path]
      end
    else
      @page ||= Page.root
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
    @page = Page.new(:url => @full_path.andand.map(&:urlize).andand.join('/') || '')
    respond_to do |wants|
      wants.html { render :action => 'page_not_found' }
      wants.js   { render :action => 'page_not_found' }
    end
  end

  private
  def resource_name
    'page'
  end
  helper_method :resource_name
end
