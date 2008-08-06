require File.join(File.dirname(__FILE__), '../helper')

require_step_group :selenium
#require_step_group :webrat
require_step_group :database

#with_steps_for :webrat, :database do
#  run_story :anonymous_visit
#end        

with_steps_for :selenium, :database do                        
  run_story :anonymous_visit
end  

