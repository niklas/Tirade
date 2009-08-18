# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key => '_tirade-v2_session',
  :secret      => '9ca10e0b49d90f6bcab2b8fe9ffd811d3ddaa51d4c35f21a1c6936eb08bfe13a1aaf31690f6cbf2a7c234ecd5f25c90b2a9498feb89749fd32bd01f582162abd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :mem_cache_store

#ActionController::Dispatcher.middleware.insert_before(
#  ActionController::Session::CookieStore, 
#  FlashSessionCookieMiddleware, 
#  ActionController::Base.session_options[:key]
#)
