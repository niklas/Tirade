class AdminController < ApplicationController
  layout 'admin'

  def index
    @contents = Content.find :all
    set_roles
  end

  def show
  end

  def list
  end
end
