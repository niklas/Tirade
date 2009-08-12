require 'lockdown'

# FIXME monkey patch until it can be overwritten cleanly
module Lockdown::Frameworks::Rails::Controller::Lock
  include AuthenticatedSystem
end
