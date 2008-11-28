module Tirade
  module ActiveRecord
    class << self
      def enable
        enable_active_record
      end

      def enable_active_record
        require 'tirade/active_record/acts_as'
        ActsAs::FEATURES.each do |feature|
          require "tirade/active_record/#{ feature }"
          ::ActiveRecord::Base.send :include, "Tirade::ActiveRecord::#{ feature.to_s.classify }".constantize
        end
      end
    end
  end
end
