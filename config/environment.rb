# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')


Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  config.plugins = [ :theme_support, :all ]
  config.gem 'haml', :version => '>=2.2.12'
  config.gem 'RedCloth', :lib => 'redcloth'
  config.gem 'andand'
  config.gem 'mime-types', :lib => 'mime/types'
  config.gem 'searchlogic', :version => '>=2.3.9', :source => 'http://gemcutter.org'
  config.gem 'binarylogic-authlogic', :source => 'http://gems.github.com', :lib => 'authlogic'
  config.gem 'libxml-ruby', :version => '>=1.1.3', :lib => 'xml'
  config.gem 'lockdown', :lib => false, :version => '1.3.2', :source => 'http://gemcutter.org'
  config.gem 'collectiveidea-awesome_nested_set', :source => 'http://gems.github.com', :version => '1.4.2', :lib => 'awesome_nested_set'
  config.gem 'saturnflyer-acts_as_tree', :source => 'http://gems.github.com', :version => '1.2.3', :lib => 'acts_as_tree'
  config.gem 'collectiveidea-delayed_job', :lib => 'delayed_job', :source => 'http://gems.github.com'

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( 
    #{RAILS_ROOT}/app/middleware 
    #{RAILS_ROOT}/app/filters 
    #{RAILS_ROOT}/app/tags 
    #{RAILS_ROOT}/app/controllers/part
    #{RAILS_ROOT}/lib/jobs
  )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
end
