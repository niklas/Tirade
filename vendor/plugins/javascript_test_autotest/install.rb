# 1. Copy across script/rstakeout and script/js_autotest into applications' script/ folder.
RAILS_ROOT = File.dirname(__FILE__) + "/../../.." unless Object.const_defined?("RAILS_ROOT")
require 'fileutils'

script_dir = File.join(File.dirname(__FILE__), "script")
%w[rstakeout js_autotest].each do |script|
  # puts "Copying #{script} to script/..."
  FileUtils.cp "#{script_dir}/#{script}", "#{RAILS_ROOT}/script/", :preserve => true, :verbose => true
  FileUtils.chmod 0755, "#{RAILS_ROOT}/script/#{script}"
end


unless File.exists?(assets = "#{RAILS_ROOT}/test/javascript/assets")
  `ln -s ../../vendor/plugins/javascript_test/assets/ #{assets}`
end


unless File.exists?(config = "#{RAILS_ROOT}/config/javascript_test_autotest.yml")
  FileUtils.cp File.dirname(__FILE__) + "/config.yml.sample", config, :verbose => true
  puts "Edit config/javascript_test_autotest.yml for the browser(s) to use for autotesting."
end
