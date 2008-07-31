class JavascriptsController < ApplicationController
  skip_before_filter :set_current_permissions
  skip_before_filter :check_permissions
  def named_routes
  end
end
