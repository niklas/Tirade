ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'spec'
require 'spec/rails'

require File.dirname(__FILE__) + '/css_spec_helper'
include CssSpecHelper
include AuthenticatedTestHelper

Spec::Runner.configure do |config|
  config.fixture_path = "#{File.dirname(__FILE__)}/../spec/fixtures"
end
