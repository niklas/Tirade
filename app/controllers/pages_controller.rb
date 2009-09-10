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

  def update_page_on_moved(page)
    super
    page.clear
    page.insert_page(object.parent)
  end

  private
  def show_if_fresh(page, thepage=@page)
    if thepage.fresh?
      page.clear
      page.insert_page(thepage)
      page.focus_on(thepage)
    end
  end

  def collection
    end_of_association_chain.roots
  end

  def index_view
    'tree'
  end

end
