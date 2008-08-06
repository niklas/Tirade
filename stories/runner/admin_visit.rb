require File.join(File.dirname(__FILE__), '../helper')

with_steps_for :selenium, :database, :authorization do
  run_story :admin_visit
end  
