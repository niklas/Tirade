class UserSession < Authlogic::Session::Base
  #logout_on_timeout true

  # to satisfy interface helper
  def table_name
    'user_sessions'
  end

  def resource_name
    'user_session'
  end

  def controller_name
    'user_sessions'
  end

  def title
    "Session"
  end
end
