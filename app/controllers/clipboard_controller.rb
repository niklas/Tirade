class ClipboardController < ApplicationController
  before_filter :prepare_clipboard
  protect_from_forgery :only => []
  def index
  end

  def create
    @clipboard << params[:id]
    render :action => 'index'
  end

  def destroy
    @clipboard.delete params[:id]
    render :action => 'index'
  end

  private
  def prepare_clipboard
    @clipboard = Clipboard.new(session)
  end
end

