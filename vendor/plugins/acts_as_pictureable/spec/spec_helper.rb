ENV['RAILS_ENV'] = 'test'

require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'spec'
require 'spec/rails'

# =======
# = Log =
# =======
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')

# ============
# = Database =
# ============
plugin_db_dir = File.dirname(__FILE__) + '/db'
databases = YAML::load(IO.read(plugin_db_dir + '/database.yml'))
ActiveRecord::Base.establish_connection(databases[ENV['DB'] || 'sqlite3'])
load(File.join(plugin_db_dir, 'schema.rb'))
