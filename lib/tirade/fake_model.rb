module Tirade
  module FakeModel
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        extend ClassMethods
      end
    end

    module ClassMethods
      def acts_as?(*args)
        false
      end
    end
  
    module InstanceMethods
    end
  end
end
