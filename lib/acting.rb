module Acting
  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end
  module InstanceMethods
    def acts_as?(role)
      self.class.acts_as?(role)
    end
  end
  module ClassMethods
    def acts_as?(role)
      acting_roles.include?(role.to_sym)
    end
    def acting_roles
      @@acting_roles ||= []
    end
    def acts_as!(role)
      acting_roles << role.to_sym
    end
  end
end

ActiveRecord::Base.class_eval { include Acting }
