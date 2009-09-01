set :application, (ENV['NAME'] || "tirade")
set :scm, :git
set :repository,  "git://github.com/niklas/Tirade.git" 
set :git_enable_submodules,1
set :local_repository, "."
set :branch, 'master'

set :target, (ENV['TARGET'] || ENV['Target'] || ENV['target'])
if target.nil? || target.empty?
  puts "please give a TARGET which is defined in config/targets"
  exit
end

load "config/targets/#{target}"

namespace :deploy do
  task :after_symlink, :roles => [:app] do
    shared_dir = "#{deploy_to}/shared"
    config_dir = "#{shared_dir}/config"
    shared_to_current = "{#{shared_dir}/,#{current_release}}"

    run "mkdir -p #{config_dir}"

    run "ln -fs #{shared_to_current}/config/application.yml" 
    run "ln -fs #{shared_to_current}/config/database.yml" 

    run "mkdir -p #{deploy_to}/shared/public/upload" 
    run "ln -fs #{shared_to_current}/public/upload"

    themes_dir = "#{shared_dir}/themes"
    run "mkdir -p #{themes_dir}/" 
    run "find -P #{themes_dir}/ -mindepth 1 -maxdepth 1 -type d -exec ln -fs {} #{current_release}/themes/ ';'; true"

    plugins_dir = "#{shared_dir}/plugins"
    run "mkdir -p #{plugins_dir}/" 
    run "find -P #{plugins_dir}/ -mindepth 1 -maxdepth 1 -type d -exec ln -fs {} #{current_release}/vendor/plugins/ ';'; true"
    update_plugins
    update_themes

    sudo "chmod -R a+rwX #{deploy_to}/shared/public/upload" 
    sudo "chmod -R a+rwX #{current_release}/tmp" 
  end

  desc "Update all themes with git"
  task :update_themes do
    run "find -P #{deploy_to}/shared/themes -mindepth 1 -maxdepth 2 -type d -name '.git' -execdir git pull ';'; true"
  end
  desc "Fix all themes with git (reset --hard)"
  task :fix_plugins do
    run "find -P #{deploy_to}/shared/themes -mindepth 1 -maxdepth 2 -type d -name '.git' -execdir git reset --hard ';'; true"
  end
  desc "Update all plugins with git"
  task :update_plugins do
    run "find -P #{deploy_to}/shared/plugins -mindepth 1 -maxdepth 2 -type d -name '.git' -execdir git pull origin master';'; true"
  end
  desc "Fix all plugins with git (reset --hard)"
  task :fix_plugins do
    run "find -P #{deploy_to}/shared/plugins -mindepth 1 -maxdepth 2 -type d -name '.git' -execdir git reset --hard ';'; true"
  end

  desc "Restart Passenger by touching"
  task :restart, :roles => [:app] do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "Dirty update git by pulling from origin"
  task :update, :roles => [:app] do
    run "cd #{current_release} && git pull origin master"
  end

  desc "Dirty update and restart"
  task :upgrade, :roles => [:app] do
    update
    restart
  end
end

# give block with |aText,aStream,aState| that returns response or nil
def run_respond(aCommand)
 run(aCommand) do |ch,stream,text|
 	ch[:state] ||= { :channel => ch }
 	output = yield(text,stream,ch[:state])
 	ch.send_data(output) if output
 end
end

namespace :db do
  task :download, :roles => [:db] do
    run_respond "cd #{current_release} && rake db:dump_production" do |text,stream,state|
      case text
        when /Password:/ then 
          Capistrano::CLI.password_prompt("production db #{text}")+"\n"	# this prompts the local user with the remote prompt text, then returns the result
      end        
    end
    get '/tmp/production.sql', '/tmp/production.sql'
    run "cd #{current_release} && rake db:remove_production_dump"
  end
end

