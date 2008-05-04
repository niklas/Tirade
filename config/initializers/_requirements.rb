# We want all models preloaded, because we want to access ARB.sublcasses,
# see: http://dev.rubyonrails.org/ticket/11269
Dir.glob(File.join(RAILS_ROOT,'app','models','**','*.rb')).each do |file|
  require_dependency file
end

gem 'andand'
require 'andand'
require 'monkey_patches'
require 'libxml'
require 'has_finder'

