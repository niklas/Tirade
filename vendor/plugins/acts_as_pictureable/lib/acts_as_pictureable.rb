module AlexPodaras
  module Acts
    
    module Pictureable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_pictureable(options = {})
          has_one :picture, :as => :pictureable, :dependent => :destroy
        end
      end    
    end  
  
  end
end