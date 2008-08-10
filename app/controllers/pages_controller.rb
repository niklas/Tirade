class PagesController < ApplicationController
  feeds_toolbox_with :page


  private
  def show_if_fresh(page)
    if @page.fresh?
      page.clear
      page.insert_page(@page)
    end
  end
  alias :after_update_toolbox_for_show :show_if_fresh
  alias :after_update_toolbox_for_created :show_if_fresh
  alias :after_update_toolbox_for_updated :show_if_fresh

end
