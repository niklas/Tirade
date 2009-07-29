class PagesController < ManageResourceController::Base

  def preview
    if @page = Page.find_by_id(params[:id])
      Page.without_modification do
        respond_to do |wants|
          wants.js do
            render :update do |page|
              if @page.update_attributes(params[:page])
                page.clear
                page.insert_page(@page)
              end
            end
          end
        end
      end
    end
  end

  def update_page_on_show(page)
    super
    page.select("div.page_#{@page.id}").trigger('tirade.focus')
  end

  private
  def show_if_fresh(page)
    if @page.fresh?
      page.clear
      page.insert_page(@page)
    end
  end
  # TODO re-enable hooks
  #alias :after_update_toolbox_for_show :show_if_fresh
  #alias :after_update_toolbox_for_created :show_if_fresh
  #alias :after_update_toolbox_for_updated :show_if_fresh


end
