# A singular resource to manage the actual login and logout process.
# Basically a login is creating a session and logout is destroying a
# session.
#
# Note that this session is different from the Rails session. This
# has to do with a login session and not session for storing temp
# data (although on logout it does clear the entire session, this
# behavior might change in the future)
class SessionsController < ApplicationController
  include Login::UsernameFinder
  authentication_required :except => [:new, :create]

  # Displays form login a user (i.e. create a new session)
  def new
    redirect_to_successful_login and return if
      session[:return_location].blank? && current_user
    @user = User.new params[:user]
  end

  # Processes a login
  def create
    username = params[:user][username_field]
    @user = User.find :first, :conditions =>
      ["#{username_field} = ?", username]

    if @user && @user.authenticate(params[:user][:password])
      cookies[:remember_me] = {
        :value => "#{@user.id};#{@user.assign_token('remember me')}",
        :expires => 10.years.from_now #That should be long enough :)
      } if params[:user][:remember_me]
      @user.save!

      # To prevent session hijacking
      return_location = session[:return_location]
      reset_session
      session[:return_location] = return_location
      session[:uid] = @user.id
      flash[:notice] = 'Login Successful'
      redirect_to_successful_login and return
    end

    @user = User.new username_field.to_sym => username if @user.nil?
    flash[:warning] = 'Username/Password Incorrect'
    render :action => 'new'
  end

  # User Logout. We assume all session should be cleared out (including
  # session data). If this is not the case overwrite in the application
  def destroy
    reset_session
    cookies[:remember_me] = nil

    url = if request.relative_url_root.blank?
      '/'
    else
      request.relative_url_root
    end
    url = LOGOUT_LOCATION if Object.const_defined? 'LOGOUT_LOCATION'
    redirect_to url
  end

  private

  def redirect_to_successful_login
    url = home_url
    url = session[:return_location] unless
      session[:return_location].blank?
    session[:return_location] = nil
    redirect_to url
  end
end
