begin
  APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/application.yml")[RAILS_ENV].with_indifferent_access
rescue
  STDERR.puts "could not find config/application.yml - some features/setting may be missing."
end

SITE_URL = APP_CONFIG[:url] || 'http://localhost:3000'

# This preloads the content types so that they are registered as Tirade::ActiveRecord::Content

APP_CONFIG[:content_types].each do |typ|
  typ.to_s.constantize
end
