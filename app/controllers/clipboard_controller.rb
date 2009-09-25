class ClipboardController < ApplicationController
  include ManageResourceController::Clipboard
  protect_from_forgery :only => []
  def index
  end

  def create
    @clipboard << params[:id]
    render :action => 'index'
  end

  def destroy
    @clipboard.delete params[:id]
    render :text => ''
  end
end

