class StylesheetsController < ApplicationController
  skip_before_filter :set_current_permissions
  skip_before_filter :check_permissions
  def permissions
    @roles = Role.find(:all)
    render :template => 'permissions.ncss'
  end
end
