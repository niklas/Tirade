ActionController::Routing::Routes.draw do |map|

  map.from_plugin :loginui

  map.resources :grids

  map.stylesheets 'stylesheets/:action.:format', :controller => 'stylesheets'
  map.javascripts 'javascripts/:action.:format', :controller => 'javascripts'
  # map.root :controller => "welcome"


  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
