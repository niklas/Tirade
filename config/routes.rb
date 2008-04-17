ActionController::Routing::Routes.draw do |map|

  map.resources :renderings

  map.resources :contents

  map.resources :pages

  map.resources :parts,
    :member => {:preview => :put}


  map.from_plugin :loginui

  map.resources :grids,
    :member => {:create_child => :post}

  map.stylesheets 'stylesheets/:action.:format', :controller => 'stylesheets'
  map.javascripts 'javascripts/:action.:format', :controller => 'javascripts'
  map.root :controller => "public"


  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.conntent '*path', :controller => 'public', :action => 'index'
end
