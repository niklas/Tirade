# This controller handles the login/logout function of the site.  

class SessionsController < ApplicationController
  skip_before_filter :check_permissions
  skip_before_filter :login_required

  helper :interface
  helper :toolbox

  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      set_roles
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      flash[:notice] = "Logged in failed. Is your name and password correct?"
      respond_to do |wants|
        wants.js   { render :action => 'new' }
        wants.html { render :action => 'new' }
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    cookies.delete :roles
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  def model_name
    'session'
  end
end
