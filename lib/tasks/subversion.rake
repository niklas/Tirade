namespace :svn do
  desc 'Prepare rails project in order to import it to a subversion repository'
  task :prepare do
    `mv config/database.yml config/database_example.yml`
    `rm -r log/*`
    `rm -r tmp/*`
    puts 'Rails project is ready for import'
    puts 'ex: svn import . http://svn.example.com/trunk -m "Initial project import"'
  end
  
  desc 'SVN Ignore on database.yml, tmp/*, db/*.sqlite3, and log/* and then commit'
  task :ignore do
    `svn propset svn:ignore database.yml config/`
    `svn propset svn:ignore "*" tmp/`
    `svn propset svn:ignore "*" log/`
    `svn propset svn:ignore "*.sqlite3" db/`
    puts `svn commit -m "Subversion ignore on database.yml, tmp/*, db/*.sqlite3 and log/*"`
  end
  
  desc 'Create the database.yml from database_example.yml'
  task :create_database_yaml do
    `cp config/database_example.yml config/database.yml`
  end
  
  desc 'Configure subversion working folder for rails'
  task :configure => [:create_database_yaml, :ignore]
  
  desc 'Add the fresh files to subversion repository'
  task :add do
     puts `svn status | grep '^\?' | sed -e 's/? *//' | sed -e 's/ /\ /g' | xargs svn add`
  end
  
  desc 'Remove the non existent files from the repository'
  task :rm do
    puts `svn status | grep ! | awk '{ print $2 }' | xargs svn rm`
  end
end