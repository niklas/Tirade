ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'spec'
require 'spec/rails'
require 'spec/database_setup'

include DatabaseSetup

Spec::Runner.configure do |config|
  config.fixture_path = "#{File.dirname(__FILE__)}/../spec/fixtures"
  config.before(:each) do
    setup_db
  end
  config.after(:each) do
    teardown_db
  end
  config.after(:all) do
    teardown_db
  end
end
