# don't drop the test database; migrate it back to 0
Rake::TaskManager.class_eval do
  def delete_task(task_name)
    @tasks.delete(task_name.to_s)
  end
  Rake.application.delete_task("db:test:purge")
  Rake.application.delete_task("db:test:clone")
end

namespace :db do
  namespace :test do
    task :purge do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations["test"])
      ActiveRecord::Migrator.migrate("db/migrate/", 0)
    end
    task :clone do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations["test"])
      ActiveRecord::Migrator.migrate("db/migrate/")
    end
  end
end

