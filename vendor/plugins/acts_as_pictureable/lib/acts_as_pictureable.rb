module AlexPodaras
  module Acts
    
    module Pictureable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_pictureable(options = {})
          has_many :picturizations, :as => :pictureable, :dependent => :destroy
          has_many :images, :as => :pictureable, :dependent => :destroy, :through => :picturizations, :order => 'position'
          acts_as! :pictureable
          if defined?(Image) && Image < ActiveRecord::Base
            unless Image.reflections.has_key?(:picturizations)
              Image.has_many :picturizations
            end
          else
            # TODO what to do without an Image class. Cry?
          end
          include InstanceMethods
          alias_method_chain :image_ids=, :robustness
          if self.accessible_attributes
            self.accessible_attributes << 'image_ids'
          end
          if self.protected_attributes
            protected_attributes.delete 'image_ids'
          end
        end
      end

      module InstanceMethods
        def image_ids_with_robustness=(new_ids_from_params)
          new_ids = new_ids_from_params.collect(&:to_i).compact.select(&:nonzero?).uniq
          if new_ids != image_ids
            transaction do
              self.image_ids_without_robustness = new_ids
            end
          end
        end
        def image
          images.first
        end
      end
    end  
  
  end
end
