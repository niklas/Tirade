ActionController::Routing::Routes.draw do |map|
  
  map.with_options :path_prefix => '/manage' do |manage|
    manage.admin 'admin/:action/:id', :controller => 'admin'
    manage.resources :renderings,
      :member => {:preview => :put, :duplicate => :put} do |renderings|
      renderings.resource :grid, :controller => 'rendering/grid'
      renderings.resource :part, :controller => 'rendering/part'
      renderings.resource :content, :controller => 'rendering/content'
    end

    manage.resources :contents

    manage.resources :pages

    manage.resources :parts,
      :member => {:preview => :put}
      
    manage.resources :grids,
      :member => {:create_child => :post, :order_renderings => :post}
      
    manage.resources :users, 
      :member => {:suspend   => :put,
                  :unsuspend => :put,
                  :purge     => :delete}

    manage.resources :images,
      :member => {:set_image_title => :post}
      
    # TODO just for completeness
    manage.resources :videos

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
