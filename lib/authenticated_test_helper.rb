require 'authlogic/test_case'
module AuthenticatedTestHelper
  def login_as(user=:valid_user)
    activate_authlogic
    UserSession.create Factory.build(user)
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end

end
