module Tirade
  module ActiveRecord
    # Provides some functionality to modules that enhance ActiveRecord 
    # with acts_as_something
    module ActsAs 
      # All ActiveRecord addons
      FEATURES = [ :content, :associations ]

      class << self
        def included(base) #:nodoc:
          base.instance_variable_set "@symbols", Array.new
          base.extend ClassMethods
        end
      end

      module ClassMethods #:nodoc:
        def symbols
          @symbols
        end

        def register_class(klass)
          @symbols |= Array(klass.to_s.tableize.to_sym)
        end

        def unregister_class(klass)
          symbols.delete(klass.to_s.tableize.to_sym) if symbols
        end

        def classes
          class_names.map(&:constantize)
        end

        def class_names
          @symbols.map(&:to_s).map(&:classify)
        end
      end
    end
  end
end
