#require_dependency 'controllers/application'
require 'mock_controller'
module ActiveRecord
  module Acts #:nodoc:
    module Renderer #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end
    
      # Allows models to support render_to_file and render_to_string methods
      module ClassMethods
        def active_controller=(ac)
          @@active_controller = ac
        end

        def active_controller
          @@active_controller ||= MockController.new 
        end
        def acts_as_renderer
          class_eval <<-EOV, __FILE__, __LINE__
            include ActiveRecord::Acts::Renderer::InstanceMethods
            require_dependency 'controllers/application'
          
            # Renders a template to a file with the included variable assignments
            def self.render_file(template, destination, assigns)
              if output = render_string(template, assigns)
                File.open(destination, 'w') do |file|
              	  file.write output
            	  end
              end
            end

            # Renders a template to a string with the included variable assignments
            def self.render_string(render_template, assigns, contr)
              controller = contr 
              path = controller.view_paths rescue controller.view_root
              template = ActionView::Base.new(path, assigns, controller)
              template.template_format = :html
              template.extend controller.master_helper_module
              template.render(render_template)
            end
          EOV
        end
      end
      
      # For instance, if your model is HomePage, you could say:
      # home_page.render_to_file('page', "#{self.user.name}/page.html", :now => Time.now)
      # and the destination file would be rendered using the template 'page', with the instance
      # variables @now and @home_page populated with Time.now and the current instance, respectively
      # The functions render_to_file and render_to_string work the same way.
      module InstanceMethods
        # Renders a record instance to a file using the provided template and any additional variables.
        def render_to_file(template, destination, variables={})
          assigns = variables.reverse_merge(self.class.class_name.underscore.to_sym => self)
          self.class.render_file(template, destination, assigns)          
        end

        # Renders a record instance to a string using the provided template and additional variables.
        def render_to_string(template, variables={})
          assigns = variables.reverse_merge(self.class.class_name.underscore.to_sym => self)
          self.class.render_string(template, assigns, active_controller)
        end

        def active_controller=(ac)
          self.class.active_controller = ac
        end

        def active_controller
          self.class.active_controller || MockController.new 
        end
      end
    end
  end
end
