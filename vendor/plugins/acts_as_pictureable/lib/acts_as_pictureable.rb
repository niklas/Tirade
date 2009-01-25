module AlexPodaras
  module Acts
    
    module Pictureable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_pictureable(options = {})
          has_many :picturizations, :as => :pictureable, :dependent => :destroy
          has_many :images, :as => :pictureable, :through => :picturizations, :order => 'position'
          robustify_has_many :images
          robustify_has_many :picturizations
          acts_as! :pictureable
          if defined?(Image) && Image < ActiveRecord::Base
            unless Image.reflections.has_key?(:picturizations)
              Image.has_many :picturizations
            end
          else
            # TODO what to do without an Image class. Cry?
          end
          include InstanceMethods
          if self.accessible_attributes
            self.accessible_attributes << 'image_ids'
          end
          if self.protected_attributes
            protected_attributes.delete 'image_ids'
          end
        end
      end

      module InstanceMethods
        def image
          images.first
        end
      end
    end  
  
  end
end
