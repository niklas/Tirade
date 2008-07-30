class StylesheetsController < ApplicationController
  def permissions
    @roles = Roles.find(:all)
    render :template => 'permissions.ncss'
  end
end
