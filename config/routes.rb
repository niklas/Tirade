ActionController::Routing::Routes.draw do |map|

  map.filter :locale

  # /manage or /api ? 
  map.with_options :path_prefix => '/manage' do |manage|
    manage.admin 'admin/:action/:id', :controller => 'admin'
    manage.resources :renderings,
      :member => {:preview => :put, :duplicate => :put}

    # TODO external preview
    manage.resources :pages, :member => {:preview => :put} do |pages|
      pages.resource :layout, :controller => 'pages/layout'
    end

    # TODO external preview
    manage.resources :parts, :member => {:preview => :put} do |parts|
      parts.resources :theme, :controller => 'part/theme', :only => [:show, :destroy]
      parts.resources :plugin, :controller => 'part/plugin', :only => [:show, :destroy]
    end

    manage.resources :jobs, :except => [:edit, :update]
    manage.create_export_job 'jobs/export_job', :controller => :jobs, :action => :create_export, :method => :post
    manage.create_reseller_export_job 'jobs/reseller_export_job', :controller => :jobs, :action => :create_reseller_export, :method => :post

    #manage.part_theme 'part/:id/theme/:theme', :controller => 'part/theme', :action => 'show'
    #manage.delete_part_theme 'part/:id/theme/:theme', :controller => 'part/theme', :action => 'delete', :conditions => {:method => :delete}
      
    # TODO external preview
    manage.resources :grids,
      :member => {:create_child => :post, :order_renderings => :post, :order_children => :post, :explode => :delete, :preview => :put}
      
    manage.resources :users, 
      :member => {:suspend   => :put,
                  :unsuspend => :put,
                  :purge     => :delete}

    manage.resources :user_groups
    manage.resources :permissions

    manage.resource :clipboard, :controller => 'clipboard'


    manage.resources :contents,
      :member => {:preview => :put}
    Tirade::ActiveRecord::Content.classes.each do |klass|
      manage.resources klass.controller_name, :member => {:preview => :put, :move => :put}, :collection => {:scopes => :get}
    end

    manage.resource :account, :except => [:index]

  end
  
  map.with_options :controller => 'users' do |page|    
    page.activate '/activate/:activation_code', :action => 'activate', :activation_code => nil
    page.signup '/signup', :action => 'new'
    page.forgot_password '/forgot_password', :action => 'forgot_password'
    page.reset_password '/reset_password/:id', :action => 'reset_password'
  end
  
  map.resources :user_sessions, :only => [:new, :create, :destroy]
  map.with_options :controller => 'user_sessions' do |page|
    page.login '/login', :action => 'new'
    page.logout '/logout', :action => 'destroy'
    page.dashboard '/dashboard.js', :action => 'show'
    page.status '/status.js', :action => 'show'
  end

  map.custom_image 'upload/images/:id/custom/:geometry/:filename', :controller => 'images', :action => 'custom', 
    :requirements => { :geometry => /([x0-9]+)/i, :filename => /[^\/]*/ }, :conditions => {:method => :get}

  map.stylesheets 'stylesheets/:action.:format', :controller => 'stylesheets', :format => 'css'
  map.javascripts 'javascripts/:action.:format', :controller => 'javascripts', :format => 'js'
  map.root :controller => "public"


  # Do not install defaulit routes. we define all we need above
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'

  map.themeing

  map.public_content '*path', :controller => 'public', :action => 'index'
end
