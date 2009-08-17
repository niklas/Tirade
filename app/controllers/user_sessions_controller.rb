class UserSessionsController < ManageResourceController::Base
  skip_before_filter :login_required, :except => [:edit, :update, :destroy]
  after_filter :set_lockdown_values, :only => :create
  def show
    @user_session = current_user_session
  end
  def destroy
    current_user_session.destroy
    reset_lockdown_session
    flash[:notice] = "Logout successful!"
    redirect_to root_path
  end
  private
  def update_page_on_create(page)
    # do NOT render 'show'
    page.toolbox.frame_by_href(dashboard_path).refresh
    page.toolbox.frame_by_href(login_path).remove()
    page.toolbox.goto(0)
    page.history.sync()
  end

  def set_lockdown_values
    if user = @user_session.user
      add_lockdown_session_values(user)
    end
  end
end
