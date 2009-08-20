$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'user'
::User.class_eval { include ::StylishPermissions::User }
