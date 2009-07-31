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
    show_if_fresh(page)
  end

  def update_page_on_update(page)
    super
    show_if_fresh(page)
  end
  def update_page_on_create(page)
    super
    show_if_fresh(page)
  end

  private
  def show_if_fresh(page)
    if @page.fresh?
      page.clear
      page.insert_page(@page)
      page.focus_on(@page)
    end
  end

end
