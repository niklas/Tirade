require 'authlogic/test_case'
module AuthenticatedTestHelper
  def login_as(user_sym=:valid_user, opts={})
    activate_authlogic
    user = Factory.build(user_sym)
    if groups = opts.delete(:groups) || opts.delete(:user_groups)
      groups.each do |group|
        user.user_groups << UserGroup.find_by_symbolic_name!(group)
      end
    end
    sess = UserSession.create user
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end

end
