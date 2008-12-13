begin
  APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/application.yml")[RAILS_ENV]
rescue
  puts "could not find config/application.yml - some features/setting may be missing."
end

SITE_URL = APP_CONFIG[:url] || 'http://localhost:3000'
