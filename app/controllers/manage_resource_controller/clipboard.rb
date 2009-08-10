module ManageResourceController
  module Clipboard

    def self.included(base)
      base.class_eval do
        before_filter :prepare_clipboard
        after_filter :add_created_model_to_clipboard, :only => [:create]
      end
    end

    private

    def prepare_clipboard
      @clipboard ||= ::Clipboard.new(session)
    end

    def add_created_model_to_clipboard
      @clipboard << object if @object && !@object.new_record?
      true
    end


  end
end
