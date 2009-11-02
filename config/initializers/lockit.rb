# we bring our own logged_in? method in AuthenticatedSystem
#
# because Lockdown includes a Module with this method into AController::Base or
# ApplicationController (dependant of the RAILS_ENV) we remove it completely. 
Lockdown::Session.module_eval do
  remove_method :logged_in?
end
