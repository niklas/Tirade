require_plugin 'restful_authentication'
require_plugin 'toolbox'

require 'user'
User.class_eval { include ::StylishPermissions::User }
