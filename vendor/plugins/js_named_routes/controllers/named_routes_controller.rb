class NamedRoutesController < ApplicationController
  caches_page :generate
  skip_before_filter :login_required

  self.view_paths = File.join(File.dirname(__FILE__), '../views/named_routes')
  layout nil

  def generate
    respond_to do |format|
      format.js { render :template => 'generate' }
    end
  end
end
