module ActionView #:nodoc:
  class TemplateFinder #:nodoc:
    def initialize_with_desert_plugins(base, *paths)
      self.class.process_view_paths(*paths)
      initialize_without_desert_plugins base, *paths

      Desert::Manager.plugins.reverse.each do |plugin|
        append_view_path plugin.templates_path
      end
    end
    alias_method_chain :initialize, :desert_plugins
  end
end
