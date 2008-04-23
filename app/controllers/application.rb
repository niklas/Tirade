# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
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

  private
  def fetch_rendering
    @rendering = Rendering.find(params[:rendering_id])
  end
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'da7c5d7c04e209653d264f43028c248a'
end
