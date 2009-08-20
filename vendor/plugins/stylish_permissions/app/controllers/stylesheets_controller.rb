class StylesheetsController < ApplicationController
  def permissions
    @roles = Role.find(:all)
    render :template => 'permissions.ncss'
  end
end
