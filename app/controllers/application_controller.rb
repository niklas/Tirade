# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  theme :current_theme
  before_filter :require_http_auth
  before_filter :violate_mvc
  before_filter :login_required
  
  # ==================
  # = Authentication =
  # ==================
  include AuthenticatedSystem

  hide_action :check_request_authorization
  hide_action :configure_lockdown

  helper_method :current_user_is_admin?
  

  def current_theme
    @current_theme ||= (Settings.public_theme || Settings.current_theme)
  end
  hide_action :current_theme
  helper_method :current_theme

  private

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
  

  def violate_mvc
    [Grid, Rendering, Part].each { |k| k.active_controller = self }
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

  def set_roles
    roles = []
    roles << "guest"
    if logged_in?
      roles << current_user.roles_short_names unless current_user.roles.empty?
      roles << "admin" if current_user.is_admin?
    end
    cookies[:roles] = roles
  end

  before_filter :set_locale
  def set_locale
    I18n.locale = params[:locale].to_sym unless params[:locale].blank?
  end

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'da7c5d7c04e209653d264f43028c248a'
end
