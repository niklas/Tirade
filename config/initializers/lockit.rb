require 'lockdown'

# FIXME monkey patch until it can be overwritten cleanly
module Lockdown::Frameworks::Rails::Controller::Lock
          def access_denied(e)

            RAILS_DEFAULT_LOGGER.info "Access denied: #{e}"

            if Lockdown::System.fetch(:logout_on_access_violation)
              reset_session
            end
            respond_to do |format|
              format.html do
                store_location
                redirect_to Lockdown::System.fetch(:access_denied_path)
                return
              end
              format.js do
                render :template => 'user_sessions/new'
              end
              format.xml do
                headers["Status"] = "Unauthorized"
                headers["WWW-Authenticate"] = %(Basic realm="Web Password")
                render :text => e.message, :status => "401 Unauthorized"
                return
              end
            end
          end
end
