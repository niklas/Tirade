set :deploy_to, "/home/www/#{application}"
server 'lanpartei.de', :app, :web, :db, :primary => true


namespace :lanpartei do
  desc "Link all the configs from Zwinger"
  task :after_symlink, :roles => [:app] do
    config_dir = "#{deploy_to}/shared/config"
    run "mkdir -p #{config_dir}"
    run "ln -fs {#{config_dir},#{current_release}/config}/mongrel_cluster.yml"
    run "ln -fs /home/shared/etc/mongrels/#{application}.yml #{config_dir}/mongrel_cluster.yml"
    run "ln -fs #{config_dir}/database.yml #{current_release}/config/database.yml"
    puts "Make sure to create a proper database.yml (in #{config_dir})"
  end

  desc "Start your Mongrels"
  task :start, :roles => [:app] do
    run "cd #{current_release} && mongrel_rails cluster::start"
  end
  desc "Stop your Mongrels"
  task :stop, :roles => [:app] do
    run "cd #{current_release} && mongrel_rails cluster::stop"
  end
  desc "Restart your Mongrels (this MAY not work..)"
  task :restart, :roles => [:app] do
    run "cd #{current_release} && mongrel_rails cluster::restart"
  end
  desc "Updates the Zwinger recipies from lanpartei" 
  task :update do
    require 'net/http'
    require 'uri'
    new_self = Net::HTTP.get URI.parse('http://zwinger.lanpartei.de/lanpartei.rb')
    File.open(__FILE__,'w') do |file|
      file.puts new_self
    end
    puts "updated your #{__FILE__}"
  end
end
namespace :deploy do
  task :start, :roles => [:app] do
    lanpartei.start
  end
  task :stop, :roles => [:app] do
    lanpartei.stop
  end
  task :restart, :roles => [:app] do
    lanpartei.restart
  end
  task :after_symlink, :roles => [:app] do
    lanpartei.after_symlink
  end
end

