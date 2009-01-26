namespace :tirade do
  namespace :themes do
    desc "Show status (git) of all themes"
    task :status => :environment do
      Dir.glob(File.join(RAILS_ROOT,'themes','*')).each do |theme_path|
        theme_name = File.basename theme_path
        puts " == #{theme_name} =="
        puts "    #{theme_path}"
        system %Q~cd #{theme_path} && git status~
      end
    end
  end
end

