class UserSessionsController < ManageResourceController::Base
  skip_before_filter :login_required, :except => [:edit, :update, :destroy]
  def blaobject
    current_user_session
  end

  def update_page_on_create(page)
    # do NOT render 'show'
    page.toolbox.frame_by_href(dashboard_path).refresh
    page.toolbox.frame_by_href(login_path).remove()
    page.toolbox.goto(0)
  end
end
