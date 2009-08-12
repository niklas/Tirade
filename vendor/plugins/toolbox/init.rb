$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'toolbox/controller'
require 'toolbox/model'
require 'toolbox/view'

ActionController::Base.class_eval { include Tirade::Toolbox::Controller }
ApplicationController.class_eval do
  helper :toolbox
  helper :interface
end
ActiveRecord::Base.class_eval { include Tirade::Toolbox::Model }
ActionView::Base.class_eval { include Tirade::Toolbox::View }
