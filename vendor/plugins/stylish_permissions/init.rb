require_plugin 'restful_authentication'
require_plugin 'toolbox'

User.class_eval { include StylishPermissions::User }
