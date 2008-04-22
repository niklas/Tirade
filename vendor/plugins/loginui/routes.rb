# NOTE: When mapping the resources we specify the controller name even
# though we are following the Rails 2.0 convention since this plugin
# may be used in a Rails 1.x application. Eventually it will be removed
# but probably not for a while.

login '/login', :controller => 'sessions', :action => 'new'
logout '/logout', :controller => 'sessions', :action => 'destroy'
resource :session, :controller => 'sessions'

forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
update_password '/update_password', :controller => 'passwords', :action => 'edit'
resource :password, :controller => 'passwords'

register '/register', :controller => 'profiles', :action => 'new'
create_account '/create_account', :controller => 'profiles', :action => 'create'
home '/home', :controller => 'profiles', :action => 'home'
verification '/verify', :controller => 'profiles', :action => 'update', :verified => true
close_account '/close_account', :controller => 'profiles', :action => 'destroy'
resource :profile, :controller => 'profiles'