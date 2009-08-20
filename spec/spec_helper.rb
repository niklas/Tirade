# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require File.expand_path(File.dirname(__FILE__) + "/factories")
include AuthenticatedTestHelper
require File.dirname(__FILE__) + '/generic_spec_helper'
include GenericSpecHelper
require File.dirname(__FILE__) + '/rjs_spec_helper'
include RJSSpecHelper
require File.dirname(__FILE__) + '/toolbox_spec_helper'
include ToolboxSpecHelper
require 'lockdown/rspec_helper'
module Lockdown
  module RspecHelper
    def mock_user
      activate_authlogic
      user = Factory(:valid_user)
      sess = UserSession.create user
      user
    end
  end
end
include Lockdown::RspecHelper

Lockdown::Database.sync_with_db

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  config.global_fixtures = :users
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.before(:each) do
    # break MVC like in ApplicationController
    [Part, Rendering, Page].each do |klass|
      klass.active_controller = mock_controller
    end
  end
end

def simple_preview
  sp = parts(:simple_preview)
  #sp.stub!(:liquid).and_return(%Q[<h2>{{ simple_preview.title }}</h2>\n<p>{{ simple_preview.body }}</p>])
  return sp
end

def mock_controller
  controller = mock(:PublicController)
  controller.stub!(:current_theme).and_return('test')
  controller.stub!(:view_paths).and_return([ 'app/views', File.join(RAILS_ROOT,'spec','fixtures','views') ])
  controller.stub!(:master_helper_module).and_return(PublicController.new.master_helper_module)
  controller.stub!(:url_for).and_return('some-url')
  controller.stub!(:authorized?).and_return(true)
  controller
end
