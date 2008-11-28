module Tirade
  module ActiveRecord
    module Content
      include ActsAs

      def self.included(base)
        base.class_eval do
          extend ClassMethods
          include InstanceMethods
        end
      end

      module ClassMethods
        def acts_as_content(opts={})
          Tirade::ActiveRecord::Content.register_class(self)
          if liquids = opts.delete(:liquid)
            liquid_methods *liquids
          end
        end
      end

      module InstanceMethods
      end
    end
  end
end
