# Append the Toolbox template path to ActionView's view_path
module Tirade
  module Toolbox
    module View
      def self.included(base)
        base.alias_method_chain :render_file, :toolbox_model
        base.alias_method_chain :render, :toolbox_model
      end
      def render_file_with_toolbox_model(template_path, use_full_path = false, local_assigns = {})
        add_toolbox_model_view_path
        render_file_without_toolbox_model(template_path, use_full_path, local_assigns)
      end

      def render_with_toolbox_model(options = {}, local_assigns = {}, &block)
        add_toolbox_model_view_path
        render_without_toolbox_model(options, local_assigns, &block)
      end

      def add_toolbox_model_view_path
        @finder.append_view_path(
          "#{RAILS_ROOT}/vendor/plugins/toolbox/app/views/model"
        )
        if controller.is_a? ApplicationController
          @finder.prepend_view_path(
            "#{RAILS_ROOT}/app/views/#{controller.controller_name}"
          )
        end
      end
    end
  end
end
