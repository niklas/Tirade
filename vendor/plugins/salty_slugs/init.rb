require 'salty_slugs'
require 'string'
begin
  require "unicode"
rescue LoadError
  require "iconv"
end
ActiveRecord::Base.send(:include, Norbauer::SaltySlugs)
String.send(:include, Norbauer::SaltySlugs::String)
