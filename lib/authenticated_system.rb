module AuthenticatedSystem
  def self.included(base)
    base.class_eval do 
      filter_parameter_logging :password, :password_confirmation
      helper_method :current_user_session, :current_user, :logged_in?
    end
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

    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_user.login != "bob"
    #  end
    def authorized?
      logged_in?
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
      authorized? || access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      flash[:error] = "You must be logged in to access this feature."
      respond_to do |format|
        format.js do
          render :template => 'user_sessions/new'
        end
        format.html do
          store_location
          redirect_to login_url
        end
        format.xml do
          request_http_basic_authentication 'Password required to access this feature.'
        end
      end
      return false
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

end
