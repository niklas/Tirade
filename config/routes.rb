ActionController::Routing::Routes.draw do |map|
  map.routes_from_plugin(:stylish_permissions)
  map.routes_from_plugin(:toolbox)

 
  # /manage or /api ? 
  map.with_options :path_prefix => '/manage' do |manage|
    manage.admin 'admin/:action/:id', :controller => 'admin'
    manage.resources :renderings,
      :member => {:preview => :put, :duplicate => :put}
    #  do |renderings|
    #  renderings.resource :grid, :controller => 'rendering/grid'
    #  renderings.resource :part, :controller => 'rendering/part' do |part|
    #    part.resource :theme, :controller => 'rendering/part/theme'
    #  end
    #  renderings.resource :content, :controller => 'rendering/content'
    #end

    manage.resources :contents,
      :member => {:preview => :put}

    # TODO external preview
    manage.resources :pages do |pages|
      pages.resource :layout, :controller => 'pages/layout'
    end

    # TODO external preview
    manage.resources :parts,
      :member => {:preview => :put}
      
    # TODO external preview
    manage.resources :grids,
      :member => {:create_child => :post, :order_renderings => :post, :order_children => :post}
      
    manage.resources :users, 
      :member => {:suspend   => :put,
                  :unsuspend => :put,
                  :purge     => :delete}

    manage.resources :images,
      :member => {:set_image_title => :post}
      
    # TODO just for completeness
    manage.resources :videos

    manage.resource :clipboard, :controller => 'clipboard'

  end
  map.dashboard '/dashboard', :controller => 'admin'
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

  map.custom_image 'upload/images/:id/custom/:geometry/:filename', :controller => 'images', :action => 'custom', 
    :requirements => { :geometry => /([x0-9]+)/i, :filename => /[^\/]*/ }, :conditions => {:method => :get}

  map.stylesheets 'stylesheets/:action.:format', :controller => 'stylesheets'
  map.javascripts 'javascripts/:action.:format', :controller => 'javascripts'
  map.root :controller => "public"


  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.public_content '*path', :controller => 'public', :action => 'index'
end
