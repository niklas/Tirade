require 'fileutils'
require 'find'
namespace :tirade do
  namespace :export do

    @export_dir = `mktemp -t -d`
    @log        = File.join(@export_dir, 'export.log')

    task :check do
      unless File.directory? @export_dir
        puts "could not create temporary directory"
        exit 1
      end
      puts "exporting to #{@export_dir}"
    end

    desc "Purges the exported Site"
    task :purge do
      FileUtils.rm_rf @export_dir
    end

    desc "Mirrors the whole Site to the filesystem"
    task :mirror => [:check, :environment] do
      sh %Q[wget --output-file=#{@log} --directory-prefix=#{@export_dir} --force-directories --mirror http://localhost]
      theme = Settings.public_theme
      sh "rsync -a #{RAILS_ROOT}/themes/#{theme}/images #{@export_dir}/themes/#{theme}/"
      invoke :cleanup
    end

    desc "Cleans up the exported Site"
    task :cleanup do
      # Remove query params in file name (everything after a question mark)
      # to not confuse the static web server or caches/proxies
      Find.find(@export_dir) do |file|
        if file =~ /(.+)\?/
          clean = $1
          File.rename file, clean
        end
      end
    end



    desc "Send a static export to the given email address"
    task :mail, [:email] => [:mirror] do |task, args|
      zip = `mktemp -t static_export_XXXXXXXXXX`
      sh %Q[zip --recursive --no-extra -j #{zip} #{@export_dir}]
      # TODO send zip to args.email per SMTP
      invoke 'purge'
    end

    desc "Publish the static export to given host"
    task :publish, [:host] => [:mirror] do |task, args|
      # TODO load hosts from anywhere, including target dir?
      # TODO actually do the rsync, s/puts/sh
      puts %Q[rsync -avz #{@export_dir} #{args.host}:/var/www]
      invoke 'purge'
    end

  end
end
