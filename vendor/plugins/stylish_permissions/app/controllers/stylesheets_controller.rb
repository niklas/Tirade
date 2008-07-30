class StylesheetsController < ApplicationController
  def permissions
    render :template => 'permissions.ncss'
  end
end
