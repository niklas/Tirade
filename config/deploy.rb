set :application, (ENV['NAME'] || "tirade")
set :repository,  "svn://lanpartei.de/tirade/branches/tirade-v2"

load 'config/lanpartei'

namespace :deploy do
  task :after_symlink, :roles => [:app] do
    lanpartei.after_symlink
    shared_to_current = "{#{deploy_to}/shared/,#{current_release}}"
    shared_dir = "#{deploy_to}/shared"

    run "ln -fs #{shared_to_current}/config/application.yml" 

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
end

