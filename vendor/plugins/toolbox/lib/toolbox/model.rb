module Tirade
  module Toolbox
    module Model
      def self.included(base)
        base.class_eval do
          include InstanceMethods
        end
      end

      module InstanceMethods
        def class_name
          self.class.to_s
        end

        def table_name
          self.class.table_name
        end
      end
    end
  end
end
