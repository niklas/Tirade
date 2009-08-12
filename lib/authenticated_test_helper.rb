require 'authlogic/test_case'
module AuthenticatedTestHelper
  def login_as(user_sym=:valid_user, opts={})
    activate_authlogic
    user = Factory(user_sym)
    if groups = opts.delete(:groups) || opts.delete(:user_groups)
      groups.each do |group|
        user.user_groups << UserGroup.find_by_symbolic_name!(group)
      end
      user.save
    end
    sess = UserSession.create user
    controller.send :add_lockdown_session_values, user
  end

  def login_as_admin
    activate_authlogic
    admin = Factory.build(:admin)
    # TODO make her administrator
    sess = UserSession.create admin
  end

  def skip_lockdown
    controller.stub!(:check_request_authorization).and_return(true)
  end

  def helper_authorizes_all
    helper.stub!(:authorized?).and_return(true)
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end

end
