# Compatibility with authorization plugin so no configuration is
# required. I'm not really sure this works and the authorization plugin
# has less favor for me these days so I may drop it at some point.
Object.const_set('DEFAULT_REDIRECTION_HASH',
  {:controller => 'sessions', :action => 'new'}) if
  !Object.const_defined?('DEFAULT_REDIRECTION_HASH')

# Mix in functionality to all controllers
ActionController::Base.send :include, Login::ControllerIntegration

# Some helper functionality
ActionView::Base.send :include, Login::HelperIntegration