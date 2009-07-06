module Tirade
  module UnwrappedFormBuilderFields

    # rescue original methods
    def self.included(base)
      base.class_eval do
        %w( select text_field text_area select datetime_select ).each do |m|
          alias_method "#{m}_without_wrap", m
        end
      end
    end

  end
end
