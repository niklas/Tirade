ActionController::Routing::Routes.draw do |map|

  Dir.glob(File.join(RAILS_ROOT,'vendor','plugins','tirade_*')) do |path|
    name = path.sub(%r~^.*/~,'')
    map.routes_from_plugin(name.to_sym)
  end

  map.routes_from_plugin(:stylish_permissions)
  map.routes_from_plugin(:toolbox)

 
  # /manage or /api ? 
  map.with_options :path_prefix => '/manage' do |manage|
    manage.admin 'admin/:action/:id', :controller => 'admin'
    manage.resources :renderings,
      :member => {:preview => :put, :duplicate => :put}

    manage.resources :contents,
      :member => {:preview => :put}

    # TODO external preview
    manage.resources :pages do |pages|
      pages.resource :layout, :controller => 'pages/layout'
    end

    # TODO external preview
    manage.resources :parts, :member => {:preview => :put} do |parts|
      parts.resources :theme, :controller => 'part/theme', :only => [:show, :delete]
      parts.resources :plugin, :controller => 'part/plugin', :only => [:show, :delete]
    end

    #manage.part_theme 'part/:id/theme/:theme', :controller => 'part/theme', :action => 'show'
    #manage.delete_part_theme 'part/:id/theme/:theme', :controller => 'part/theme', :action => 'delete', :conditions => {:method => :delete}
      
    # TODO external preview
    manage.resources :grids,
      :member => {:create_child => :post, :order_renderings => :post, :order_children => :post, :explode => :delete}
      
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
    page.activate '/activate/:activation_code', :action => 'activate', :activation_code => nil
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

  map.stylesheets 'stylesheets/:action.:format', :controller => 'stylesheets', :format => 'css'
  map.javascripts 'javascripts/:action.:format', :controller => 'javascripts', :format => 'js'
  map.root :controller => "public"


  # Do not install defaulit routes. we define all we need above
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'

  map.public_content '*path', :controller => 'public', :action => 'index'
end
