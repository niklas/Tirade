$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'toolbox_controller'
require 'toolbox_model'
require 'toolbox_view'

ActionController::Base.class_eval { include Tirade::Toolbox::Controller }
ActiveRecord::Base.class_eval { include Tirade::Toolbox::Model }
ActionView::Base.class_eval { include Tirade::Toolbox::View }
