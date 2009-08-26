set :deploy_to, "/home/www/#{application}"
server 'gsmk', :app, :web, :db, :primary => true

set :user, 'pandur'


default_run_options[:shell] = '/usr/local/bin/bash'


