namespace :db do
  task :dump_production do
    load 'config/environment.rb'
    config = ActiveRecord::Base.configurations['production'].with_indifferent_access
    dump_file = "/tmp/production.sql"
    do_dump = "pg_dump --format=plain --clean --file=#{dump_file} --verbose --host=#{config[:host]} -W -U #{config[:username]} #{config[:database]}"
    p do_dump
    system do_dump
  end

  task :load_production_dump_into_development do
    load 'config/environment.rb'
    config = ActiveRecord::Base.configurations['development'].with_indifferent_access
    dump_file = '/tmp/production.sql'
    do_restore = "psql --host=#{config[:host]} -W -U #{config[:username]} #{config[:database]} < #{dump_file}"
    p do_restore
    system do_restore
  end

  task :remove_production_dump do
    File.delete '/tmp/production.sql'
  end
end
