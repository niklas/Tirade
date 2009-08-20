require 'authlogic/test_case'
module AuthenticatedTestHelper
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
