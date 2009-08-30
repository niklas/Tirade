module Tirade
  module ActiveRecord
    module CssClasses
      def self.included(base)
        if base.table_exists?
          if base.column_names.include?('css_classes')
            base.class_eval do
              include InstanceMethods
              serialize :css_classes, Array
              validate :must_have_only_valid_css_classes
            end
          end
        end
      end
      module InstanceMethods
        def css_classes_list=(new_classes)
          self.css_classes = new_classes.split(/\s|,/).reject(&:blank?) unless new_classes.blank?
        end
        def css_classes_list
          css_classes.andand.join(' ') || ''
        end
        def css_classes
          read_attribute(:css_classes) || []
        end
        def must_have_only_valid_css_classes
          unless css_classes.blank?
            css_classes.each do |css|
              errors.add(:css_classes, "includes invalid class: '#{css}'") unless css =~ /^[\w\-_]+$/i
            end
          end
        end
      end
    end
  end
end
