ActionController::Routing::Routes.draw do |map|

  map.resources :grids
  # map.root :controller => "welcome"


  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
