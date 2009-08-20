namespace :tirade do
  namespace :plugins do
    desc "Show status (git) of all tirade plugins"
    task :status => :environment do
      Tirade::Plugins.all_paths.each do |plugin_path|
        plugin_name = File.basename plugin_path
        puts " == #{plugin_name} =="
        puts "    #{plugin_path}"
        system %Q~cd #{plugin_path} && git status~
      end
    end

    desc "Pushes all pending commits in all tirade plugins"
    task :push => :environment do
      Tirade::Plugins.all_paths.each do |plugin_path|
        plugin_name = File.basename plugin_path
        puts "Pushing #{plugin_name}"
        puts "    #{plugin_path}"
        system %Q~cd #{plugin_path} && git push~
      end
    end

    desc "pulls updates for all tirade plugins"
    task :pull => :environment do
      Tirade::Plugins.all_paths.each do |plugin_path|
        plugin_name = File.basename plugin_path
        puts "Pulling #{plugin_name}"
        puts "    #{plugin_path}"
        system %Q~cd #{plugin_path} && git pull~
      end
    end

    desc "Migrate all tirade plugins to their latest version"
    task :migrate => :environment do
      Tirade::Plugins.all.each do |plugin|
        mignum = plugin.latest_migration_number
        if mignum > 0
          puts %Q~Migrating #{plugin.name} to #{plugin.latest_migration_number}~
          ActiveRecord::Migration.migrate_plugin plugin.name.to_sym, mignum
        end
      end
    end

    desc "Sync all stuff from plugins"
    task :sync => [:sync_migrations, :sync_icons]

    desc "Sync migrations from installed plugins"
    task :sync_migrations do
      system "rsync -uv vendor/plugins/tirade_*/db/migrate/*.rb db/migrate/"
    end

    desc "Sync content type icons from installed plugins"
    task :sync_icons do
      system "rsync -uv vendor/plugins/tirade_*/public/images/icons/types/*.png public/images/icons/types/"
    end
  end
end
