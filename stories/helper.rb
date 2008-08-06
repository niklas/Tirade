ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")        
require File.join(File.dirname(__FILE__), 'selenium')
require 'spec/rails/story_adapter'

#include FixtureReplacement   

def run_story(story_name, browser=false)
  run File.join(File.dirname(__FILE__), 'plain_text/', "#{story_name.to_s}.txt"), :type => RailsStory  
end

def require_step_group(step_file_name)
  require File.join(File.dirname(__FILE__), 'steps', "#{step_file_name.to_s}_steps.rb")
end
         
def selenium_driver
  Selenium::SeleniumDriver.new("localhost", 4444, ENV['SELENIUM_BROWSER'] || "*firefox", "http://localhost:4000", 15000)
end    

require_step_group :selenium
require_step_group :database
require_step_group :authorization
