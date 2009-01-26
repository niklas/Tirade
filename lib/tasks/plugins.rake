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
        puts " == #{plugin_name} =="
        puts "    #{plugin_path}"
        system %Q~cd #{plugin_path} && git push~
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
  end
end
