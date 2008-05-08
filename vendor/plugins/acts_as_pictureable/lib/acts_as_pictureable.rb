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
          if defined?(Image) && Image < ActiveRecord::Base
            unless Image.reflections.has_key?(:picturizations)
              Image.has_many :picturizations
            end
          else
            # TODO what to do without an Image class. Cry?
          end
          include InstanceMethods
        end
      end

      module InstanceMethods
        def image_ids=(new_ids_from_params)
          new_ids = new_ids_from_params.collect(&:to_i).compact.select(&:nonzero?).uniq
          if new_ids != image_ids
            transaction do
              self.picturizations.clear
              new_ids.each do |new_id|
                self.images << Image.find(new_id)
              end
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
