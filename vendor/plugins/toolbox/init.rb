$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'toolbox_controller'
require 'toolbox_model'

ActionController::Base.class_eval { include Tirade::Toolbox::Controller }
ActiveRecord::Base.class_eval { include Tirade::Toolbox::Model }
