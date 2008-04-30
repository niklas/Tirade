class AdminController < ApplicationController
  layout 'admin'

  def index
    @contents = Content.find :all
  end

  def show
  end

  def list
  end
end
