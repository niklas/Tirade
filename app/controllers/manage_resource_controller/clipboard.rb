module ManageResourceController
  module Clipboard

    def self.included(base)
      base.class_eval do
        before_filter :prepare_clipboard
      end
    end

    # TODO
    def prepare_clipboard
    end

  end
end
