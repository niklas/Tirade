# Add your custom routes here.  If in config/routes.rb you would 
# add <tt>map.resources</tt>, here you would add just <tt>resources</tt>

# resources :toolboxes
ActionController::Routing::Routes.draw do |map|
  map.toolbox_demo '/gui/toolbox/demo/:demo', :controller => 'toolbox', :action => 'demo', :demo => 1
end
