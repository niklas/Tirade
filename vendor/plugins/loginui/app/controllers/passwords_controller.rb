# A controller to let a user manage their password. This controller
# follows the single resource design. It is always editing the password
# of the current user.
class PasswordsController < ApplicationController
  include Login::UsernameFinder
  authentication_required :except => [:new, :create]

  # Forgot my password form. Basically we are asking for a new password
  def new
    redirect_to login_url unless User.column_names.include? 'email'
  end

  # Send forgot my password request. Basically we are starting the
  # process of creating a new password.
  def create
    redirect_to login_url and return unless
      User.column_names.include? 'email'
    user = User.find :first, :conditions =>
      {username_field => params[username_field]}
    if user
      PasswordNotifications.deliver_forgot_password user, reset_link(user)
      flash[:notice] = 'Notice sent. Please check your email.'
    else
      flash[:warning] = 'User not found.'
    end

    redirect_to login_url
  end

  # Form to edit existing password
  def edit
    @user = current_user
    redirect_to login_url and return if @user.nil?
  end

  # Will update the current user's password to the given value.
  # Will use password_confirmation if given.
  def update
    @user = current_user
    redirect_to login_url and return if @user.nil?

    @user.password = params[:user][:password]
    @user.password_confirmation =
      params[:user][:password_confirmation] if
      @user.respond_to? :password_confirmation

    if @user.save
      PasswordNotifications.deliver_updated_password @user,
        reset_link(@user) if @user.respond_to? :email
      flash[:notice] = 'Password successfully updated'
      redirect_to home_url
    else
      render :action => 'edit'
    end
  end

  private

  # Will get a link that will allow a user to reset their password
  def reset_link(user)
    token = user.assign_token 'password'
    user.save!
    token = "#{user.id};#{token}"
    reset_link = url_for :action => 'edit', :token => token
  end

end
