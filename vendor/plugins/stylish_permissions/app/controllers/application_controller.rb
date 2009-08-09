class ApplicationController < ActionController::Base
  #before_filter :set_current_permissions
  #before_filter :check_permissions
  # Check the users permissions. If the current user is allowed to access, return
  # true, otherwise redirect to '/'. This method is used as a
  # before_filter in all controllers
  def check_permissions
    return false if current_user.blank?

    controller = params[:controller]
    action = params[:action]

    # Reset the error (sticks around sometimes)
    #flash[:error] = nil

    unless current_user_may_access?(controller, action) then
      # FIXME should be 401
      render :text => "You are now allowed to #{action} #{controller}. Go away!"
      return false
    end
  end

  # Helper method that check the permissions of a user.
  # Returns true or false, but does not redirect.
  helper_method :current_user_may_access?
  def current_user_may_access?(controller, action)
    return false if current_user.blank?

    # Always return true if the user has the is_admin flag
    return true if current_user.is_admin?

    # Check if the user has permissions
    full_method = "#{controller}/#{action}"
    return current_permissions_names.include?(full_method)
  end

  # Authorize a user based on provided parameters. This method yields a
  # block if the user is authorized. This can be used to wrap code for
  # authorization
  helper_method :authorize
  def authorize(opts, &block)
    # If no controller or action options are passed in the opts hash, we
    # Get them from the request params
    controller = (opts[:controller]) ? opts[:controller] : 	
  	 params[:controller]
    action = (opts[:action]) ? opts[:action] : params[:action]

    # Yield the passed in block if the user is authorized.
    yield if current_user_may_access?(controller, action)
  end

  def current_permissions_names
    session[:current_permissions_names] || []
  end

  protected
  # TODO does not realize when a Permission (...) is deleted (no changes in #updated_at)
  def set_current_permissions
    return unless current_user
    if  session[:permissions_synced_at].nil? or
        session[:permissions_synced_at] < 15.minutes.ago or
        [Permission, UserRole, Role].any? {|k| session[:permissions_synced_at] < (k.maximum(:updated_at) || 15.minutes.ago) } then

      session[:current_permissions_names] = current_user.permissions_names
      session[:permissions_synced_at] = Time.now
    end
    true
  end
end
