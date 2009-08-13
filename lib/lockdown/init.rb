Lockdown::System.configure do

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Configuration Options
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Options with defaults:
  #
  #
  # Set User model:
  #      # make sure you use the string "User", not the constant
  #      options[:user_model] = "User"
  #
  # Set UserGroup model:
  #      # make sure you use the string "UserGroup", not the constant
  #      options[:user_group_model] = "UserGroup"
  #
  # Set who_did_it method:
  #   This method is used in setting the created_by/updated_by fields and
  #   should be accessible to the controller
  #      options[:who_did_it] = :current_user_id
  #
  # Set default_who_did_it:
  #   When current_user_id returns nil, this is the value to use
  #      options[:default_who_did_it] = 1
  #
  #   Lockdown version < 0.9.0 set this to:
  #       options[:default_who_did_it] = Profile::System
  #
  #   Should probably be something like:
  #      options[:default_who_did_it] = User::SystemId
  #
  # Set timeout to 1 hour:
  #       options[:session_timeout] = (60 * 60)
  #
  # Call method when timeout occurs (method must be callable by controller):
  #       options[:session_timeout_method] = :clear_session_values
  #
  # Set system to logout if unauthorized access is attempted:
  #       options[:logout_on_access_violation] = false
  #
  # Set redirect to path on unauthorized access attempt:
  #       options[:access_denied_path] = "/"
  #
  # Set redirect to path on successful login:
  #       options[:successful_login_path] = "/"
  #
  # Set separator on links call
  #       options[:links_separator] = "|"
  #
  # If deploying to a subdirectory, set that here. Defaults to nil
  #       options[:subdirectory] = "blog"
  #       *Notice: Do not add leading or trailing slashes,
  #                Lockdown will handle this
  #

  options[:session_timeout_method] = :clear_authlogic_session

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Define permissions
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #
  # set_permission(:product_management).
  #   with_controller(:products)
  #
  # :product_management is the name of the permission which is later
  # referenced by the set_user_group method
  #
  # .with_controller(:products) defaults to all action_methods available on that
  #  controller.  You can change this behaviour by chaining on except_methods or
  #  only_methods.  (see examples below)
  #
  #  ** To define a namespaced controller use two underscores:
  #     :admin__products
  #
  # if products is your standard RESTful resource you'll get:
  #   ["products/index , "products/show",
  #    "products/new", "products/edit",
  #    "products/create", "products/update",
  #    "products/destroy"]
  #
  # You can chain method calls to restrict the methods for one controller
  # or you can add multiple controllers to one permission.
  #      
  #   set_permission(:security_management).
  #     with_controller(:users).
  #     and_controller(:user_groups).
  #     and_controller(:permissions) 
  #
  # In addition to with_controller(:controller) there are:
  #
  #   set_permission(:some_nice_permission_name).
  #     with_controller(:some_controller_name).
  #       only_methods(:only_method_1, :only_method_2)
  #
  #   set_permission(:some_nice_permission_name).
  #     with_controller(:some_controller_name).
  #       except_methods(:except_method_1, :except_method_2)
  #
  #   set_permission(:some_nice_permission_name).
  #     with_controller(:some_controller_name).
  #       except_methods(:except_method_1, :except_method_2).
  #     and_controller(:another_controller_name).
  #     and_controller(:yet_another_controller_name)
  #
  # Define your permissions here:

  set_permission(:login).with_controller(:user_sessions)
  set_permission(:public).
    with_controller(:public).
    only_methods(:index)

  set_permission(:stylesheets).
    with_controller(:stylesheets)

  set_permission(:generated_stylesheets).
    with_controller(:stylesheets).
    only_methods(:toolbox, :toolbox_colors, :interface, :focus).
    set_as_public_access

  set_permission(:theme).
    with_controller(:theme)

  set_permission(:javascripts).
    with_controller(:javascripts).
    and_controller(:named_routes)

  set_permission(:custom_images).
    with_controller(:images).
    only_methods(:custom).
    set_as_public_access

  def set_tiered_permissions(resource)
    resource = resource.to_sym

    read = "read_#{resource}".to_sym
    set_permission(read).
      with_controller(resource).
      only_methods(:show, :index)
    set_protected_access read
    set_user_group read, read

    manage = "manage_#{resource}".to_sym
    set_permission(manage).
      with_controller(resource).
      except_methods(:destroy)
    set_protected_access manage
    set_user_group manage, manage

    admin = "admin_#{resource}".to_sym
    set_permission(admin).
      with_controller(resource)
    set_protected_access admin
    set_user_group admin, admin

  end


  Tirade::ActiveRecord::Content.symbols.each do |resource|
    set_tiered_permissions resource
  end

  %w(pages grids renderings).each do |resource|
    set_tiered_permissions resource
  end


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Built-in user groups
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #  You can assign the above permission to one of the built-in user groups
  #  by using the following:
  # 
  #  To allow public access on the permissions :sessions and :home:
  #    set_public_access :sessions, :home
  #     
  #  Restrict :my_account access to only authenticated users:
  #    set_protected_access :my_account
  #
  # Define the built-in user groups here:

  set_public_access :login
  set_public_access :public
  set_public_access :stylesheets
  set_public_access :javascripts
  set_public_access :theme

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Define user groups
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #
  #  set_user_group(:catalog_management, :category_management, 
  #                                      :product_management) 
  #
  #  :catalog_management is the name of the user group
  #  :category_management and :product_management refer to permission names
  #
  # 
  # Define your user groups here:

  set_user_group(:layout_management, :manage_pages, :manage_grids, :manage_renderings)
  set_user_group(:layout_administration, :admin_pages, :admin_grids, :admin_renderings)
end 
