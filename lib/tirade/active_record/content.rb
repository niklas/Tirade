module Tirade
  module ActiveRecord
    module Content
      include ActsAs

      def self.included(base)
        base.class_inheritable_reader :marked_up_fields
        base.class_inheritable_writer :marked_up_fields
        base.marked_up_fields = []
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
          named_scope :order_by, lambda { |o|
            if o
              {:order => o}
            else
              {}
            end
          }
        end
        def markup(*fields)
          self.marked_up_fields << fields
          self.marked_up_fields.flatten!
          self.marked_up_fields.uniq!
        end
      end

      module InstanceMethods
        def markup?(field)
          self.class.marked_up_fields.include?(field.to_sym)
        end
      end
    end
  end
end
