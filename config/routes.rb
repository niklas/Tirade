ActionController::Routing::Routes.draw do |map|

  map.with_options :path_prefix => '/manage' do |manage|
    manage.resources :renderings

    manage.resources :contents

    manage.resources :pages

    manage.resources :parts,
      :member => {:preview => :put}
      
    manage.resources :grids,
      :member => {:create_child => :post}
      
    manage.resources :users, 
      :member => {:suspend   => :put,
                  :unsuspend => :put,
                  :purge     => :delete}

  end
  map.resource :session
  
  map.with_options :controller => 'users' do |page|    
    page.activate '/activate/:activation_code', :action => 'activate'
    page.signup '/signup', :action => 'new'
    page.forgot_password '/forgot_password', :action => 'forgot_password'
    page.reset_password '/reset_password/:id', :action => 'reset_password'
  end
  
  map.with_options :controller => 'sessions' do |page|
    page.login '/login', :action => 'new'
    page.logout '/logout', :action => 'destroy'
  end

  map.stylesheets 'stylesheets/:action.:format', :controller => 'stylesheets'
  map.javascripts 'javascripts/:action.:format', :controller => 'javascripts'
  map.root :controller => "public"


  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.conntent '*path', :controller => 'public', :action => 'index'
end
