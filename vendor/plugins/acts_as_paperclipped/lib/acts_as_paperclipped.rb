module Tirade
  module Acts
    module Paperclipped
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_paperclipped
          has_many :paperclippings, :as => 'content', :dependent => :destroy
          has_many :assets, :as => 'content', :through => :paperclippings, :order => 'position'
          acts_as! :paperclipped
          include InstanceMethods
          if self.accessible_attributes
            self.accessible_attributes << 'asset_ids'
            self.accessible_attributes << 'new_asset'
          end
          if self.protected_attributes
            protected_attributes.delete 'asset_ids'
            protected_attributes.delete 'new_asset'
          end
        end
      end

      module InstanceMethods
        def asset
          assets.first
        end

        def has_asset?
          !asset.nil?
        end

        def new_asset=(asset_attributes)
          unless asset_attributes.blank? || asset_attributes[:file].blank?
            self.assets.build(asset_attributes)
          end
        end
      end
    end
  end
end
