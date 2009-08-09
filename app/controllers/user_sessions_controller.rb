class UserSessionsController < ManageResourceController::Base
  skip_before_filter :login_required, :except => [:edit, :update, :destroy]
  def blaobject
    current_user_session
  end
end
