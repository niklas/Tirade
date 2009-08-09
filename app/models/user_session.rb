class UserSession < Authlogic::Session::Base
  #logout_on_timeout true

  # to satisfy interface helper
  def table_name
    'user_sessions'
  end
end
