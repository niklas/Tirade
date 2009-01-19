module Acting
  def self.included(base)
    base.class_inheritable_reader :acting_roles
    base.class_inheritable_writer :acting_roles
    base.acting_roles = []
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end
  module InstanceMethods
    def acts_as?(role)
      self.class.acts_as?(role)
    end
    def acting_roles
      self.class.acting_roles
    end
  end
  module ClassMethods
    def acts_as?(role)
      acting_roles.include?(role.to_sym)
    end
    def acts_as!(role)
      acting_roles << role.to_sym
      acting_roles.uniq!
    end
    def acting_fields_view_path(role)
      %Q[#{RAILS_ROOT}/vendor/plugins/acts_as_#{role}/views/_fields.html.erb]
    end
    def acting_view_path(role)
      %Q[#{RAILS_ROOT}/vendor/plugins/acts_as_#{role}/views/_show.html.erb]
    end
  end
end

ActiveRecord::Base.class_eval { include Acting }
