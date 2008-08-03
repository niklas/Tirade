class PagesController < ApplicationController
  feeds_toolbox_with :page

  def after_update_toolbox_for_show(page)
    page.unmark_all_active
  end
end
