require 'fileutils'
%w[rstakeout js_autotest].each do |script|
  puts "Removing #{script} from script/..."
  FileUtils.rm_f "#{RAILS_ROOT}/script/#{script}"
end
