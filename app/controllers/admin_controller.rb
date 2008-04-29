class AdminController < ApplicationController
  layout 'admin'

  def index
    @content = Content.find :all
  end

  def show
  end

  def list
  end
end
