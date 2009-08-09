require_plugin 'toolbox'

require 'user'
User.class_eval { include ::StylishPermissions::User }
