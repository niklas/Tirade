$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'toolbox_controller'
ActionController::Base.class_eval { include Tirade::Toolbox }
