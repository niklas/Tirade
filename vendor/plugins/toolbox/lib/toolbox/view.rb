# Append the Toolbox template path to ActionView's view_path
module Tirade
  module Toolbox
    module View
      def self.included(base)
        base.alias_method_chain :view_paths, :toolbox_model
      end
      def view_paths_with_toolbox_model
        paths = view_paths_without_toolbox_model

        paths.unshift(toolbox_model_view_path) unless paths.include?(toolbox_model_view_path)

        paths
      end
      def toolbox_model_view_path
        "#{RAILS_ROOT}/vendor/plugins/toolbox/app/views/model"
      end
      def toolbox_controller_view_path
        "#{RAILS_ROOT}/app/views/#{controller.controller_name}"
      end
    end
  end
end
