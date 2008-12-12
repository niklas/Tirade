class Pages::LayoutController < ApplicationController
  before_filter :fetch_page

  def new
    @grid = Grid.new_by_yui('yui-g')
    @page.layout = @grid
    respond_to do |wants|
      wants.js
    end
  end

  def create
    Page.transaction do
      @grid = Grid.new_by_yui('yui-g')
      @grid.save!
      @page.layout = @grid
      @page.save!
    end
    respond_to do |wants|
      wants.js do
        render :update do |page|
          page.push_or_refresh(
            :title => "Page '#{@page.title}'",
            :partial => '/pages/show', :object => @page
          )
          page.remove_page
          page.insert_page(@page)
        end
      end
    end
  end

  def update
  end

  private
  def fetch_page
    @page = Page.find(params[:page_id])
  end

  def continue_editing
    respond_to do |wants|
      wants.js { render :template => '/public/index'}
    end
  end
end
