module AuthenticatedSystem
  def self.included(base)
    base.class_eval do 
      filter_parameter_logging :password, :password_confirmation
      helper_method :current_user_session, :current_user, :logged_in?
      hide_action :current_user_session, :current_user, :logged_in?, :login_required, 
        :access_denied, :store_location, :redirect_back_or_default
    end if base.is_a?(Class)
  end

  protected
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      !!current_user
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      logged_in? || access_denied(SecurityError.new('You Must be logged in to access this feature'))
    end

    # Redirect as appropriate when an access request fails.
    #
    # Overrides the prropriate method provided by Lockdown and Authlogic
    def access_denied(e)
      RAILS_DEFAULT_LOGGER.info "Access denied: #{e}"

      if Lockdown::System.fetch(:logout_on_access_violation)
        reset_session
      end
      respond_to do |format|
        format.js do
          render :action => 'new', :controller => 'user_sessions'
        end
        format.html do
          store_location
          redirect_to Lockdown::System.fetch(:access_denied_path)
          return
        end
        format.xml do
          headers["Status"] = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => e.message, :status => "401 Unauthorized"
          return
        end
      end
    end


    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      respond_to do |wants|
        wants.html { redirect_to(session[:return_to] || default) }
        wants.js do
          render :update do |page|
            if session[:return_to]
              page.toolbox.pop_and_refresh_last() 
              # TODO what else? where did we came from? was there a Toolbox frame involved?
            else
              page.toolbox.pop_and_refresh_last()
            end
          end
        end
      end
      session[:return_to] = nil
    end

    def clear_authlogic_session
      sess = current_user_session
      sess.destroy if sess
    end

end
