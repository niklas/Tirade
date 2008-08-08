class PagesController < ApplicationController
  feeds_toolbox_with :page


  def create
    @model = @page = Page.new(params[:page])
    if @page.save
      flash[:notice] = "Page #{@page.title} created."
      render_toolbox_action :show
    else
      flash[:notice] = "Creating Page failed."
      render_toolbox_action :new
    end
  end


  def after_update_toolbox_for_show(page)
    if @page.fresh?
      page.clear
      page.insert_page(@page)
    end
  end

end
