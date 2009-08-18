module ManageResourceController
  module Notifications
    def self.included(base)
      base.class_eval do
        hide_action :render_flash_messages_as_notifications
      end
    end
    def render_flash_messages_as_notifications(page)
      [:notice, :error].each do |severity|
        unless flash[severity].blank?
          page.notification(flash[severity], :title => t("flash.#{severity}"))
          flash.discard severity
        end
      end
    end
  end
end
