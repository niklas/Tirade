# Add your custom routes here.  If in config/routes.rb you would 
# add <tt>map.resources</tt>, here you would add just <tt>resources</tt>

# resources :stylish_permissions
stylish_permissions 'stylesheets/permissions.css', :controller => 'stylesheets', :action => 'permissions'
with_options :path_prefix => '/manage' do |manage|
  manage.resources :roles
  manage.resources :groups
  manage.resources :permissions
end
