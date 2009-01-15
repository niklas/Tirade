# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
include AuthenticatedTestHelper
require 'mock_controller'

require File.dirname(__FILE__) + '/toolbox_spec_helper'
include ToolboxSpecHelper

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
  # config.global_fixtures = :table_a, :table_b
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
  finder = mock(ActionView::TemplateFinder)
  def finder.pick_template(ppath,ext)
    path = File.join(RAILS_ROOT, 'spec', 'fixtures', 'views', "#{ppath}.#{ext}")
    File.exists?(path) ? path : false
  end
  view = mock(ActionView::Base)
  view.stub!(:finder).and_return(finder)

  controller = mock(PublicController)
  controller.stub!(:current_theme).and_return('cool')
  controller.stub!(:view_paths).and_return([ File.join(RAILS_ROOT,'spec','fixtures','views') ])
  controller.stub!(:master_helper_module).and_return(PublicController.new.master_helper_module)
  # there is no such thing as PublicController#template
  controller.instance_variable_set('@template', view)
  controller
end
