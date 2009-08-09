module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    Authlogic::Session::Base.controller = self
    UserSession.create user ? users(user).id : nil
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end

  #def current_user(stubs = {})
  #  @current_user ||= mock_model(User, stubs)
  #end
  # 
  #def user_session(stubs = {}, user_stubs = {})
  #  @current_user ||= mock_model(UserSession, {:user => current_user(user_stubs)}.merge(stubs))
  #end
  # 
  #def login(session_stubs = {}, user_stubs = {})
  #  UserSession.stub!(:find).and_return(user_session(session_stubs, user_stubs))
  #end
  # 
  #def logout
  #  @user_session = nil
  #end
end
