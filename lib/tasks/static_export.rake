require 'fileutils'
require 'find'
namespace :tirade do
  namespace :export do

    @export_dir = `mktemp -t -d`.chomp
    @log        = File.join(@export_dir, 'export.log')

    task :check do
      unless File.directory? @export_dir
        puts "could not create temporary directory"
        exit 1
      end
    end

    desc "Purges the exported Site"
    task :purge do
      FileUtils.rm_rf @export_dir
    end

    desc "Mirrors the whole Site to the filesystem"
    task :mirror => [:check, :environment] do
      sh %Q[wget --output-file=#{@log} --directory-prefix=#{@export_dir} --force-directories --no-host-directories --mirror http://localhost]
      theme = Settings.public_theme
      directory "#{@export_dir}/themes/#{theme}/"
      
      # Remove query params in file name (everything after a question mark)
      # to not confuse the static web server or caches/proxies
      Find.find(@export_dir + '/') do |file|
        if file =~ /(.+)\?/
          clean = $1
          File.rename file, clean
        end
      end

      sh "rsync -a #{RAILS_ROOT}/themes/#{theme}/images #{@export_dir}/themes/#{theme}/"
    end


    desc "Send a static export to the given email address"
    task :mail, [:email] => [:mirror] do |task, args|
      zip = `mktemp -t static_export_XXXXXXXXXX`.chomp + '.zip'
      sh %Q[cd #{@export_dir} && zip -rXq #{zip} .]
      # TODO send zip to args.email per SMTP
      task(:purge).invoke
    end

    desc "Publish the static export to given host"
    task :publish, [:host] => [:mirror] do |task, args|
      # TODO load hosts from anywhere, including target dir?
      # TODO actually do the rsync, s/puts/sh
      puts %Q[rsync -avz #{@export_dir} #{args.host}:/var/www]
      task(:purge).invoke
    end

  end
end
