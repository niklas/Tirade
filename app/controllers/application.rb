# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  theme :current_theme
  before_filter :require_http_auth
  before_filter :violate_mvc
  
  # ==================
  # = Authentication =
  # ==================
  include AuthenticatedSystem
  
  # When access is denied redirect to the login page.
  def access_denied
    respond_to do |format|
      format.html do
        store_location
        flash[:error] = "You must be logged in to access this feature."
        redirect_to '/login'
      end
      format.xml do
        request_http_basic_authentication 'Password required to access this feature.'
      end
    end
  end


  def current_theme
    @current_theme ||= (Settings.public_theme || Settings.current_theme)
  end
  hide_action :current_theme
  helper_method :current_theme

  # Returns the names of all controllers that should be interacted with (resourceful)
  #  * must be plural
  #  * no slashes (aka supcontrollers)
  #
  # => ["users", "roles", "images"] ...
  def primary_controller_names
    ActionController::Routing::Routes.routes.collect {|r| r.defaults[:controller] }.uniq.compact.
      reject { |c| c=~%r~/~}.
      select { |c| c=~%r~s$~ } - %w(sessions javascripts)
  end
  helper_method :primary_controller_names
  

  private
  def violate_mvc
    [Grid, Rendering, Part].each { |k| k.active_controller = self }
  end
  def fetch_rendering
    @rendering = Rendering.find(params[:rendering_id])
  end

  def require_http_auth
    if `hostname` =~ /soykaf|lanpartei/i 
      if auth =  APP_CONFIG['http_auth']
        authenticate_or_request_with_http_basic do |user_name, password|
          user_name == auth['name'] && password == auth['password']
        end      
      end
    end
  end

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

  def set_roles
    roles = []
    roles << "guest"
    if logged_in?
      roles << current_user.roles_short_names unless current_user.roles.empty?
      roles << "admin" if current_user.is_admin?
    end
    cookies[:roles] = roles
  end

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'da7c5d7c04e209653d264f43028c248a'
end
