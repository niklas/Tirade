require 'fileutils'
require 'find'
namespace :tirade do
  namespace :export do

    @export_dir = `mktemp -d`
    @log        = File.join(@export_dir, 'export.log')

    task :check do
      puts "exporting to #{@export_dir}"
    end

    desc "Purges the exported Site"
    task :purge do
      FileUtils.rm_rf @export_dir
    end

    desc "Mirrors the whole Site to the filesystem"
    task :mirror => [:check] do
      sh %Q[wget --output-file=#{@log} --directory-prefix=#{@export_dir} --force-directories --mirror http://localhost]
      # mirror assets from theme
      # TODO get current theme
      sh "rsync -a /home/www/tirade/shared/themes/gsmk/images #{@export_dir}/themes/gsmk/"
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



    task :zip, [:zip_name] => [:mirror] do |task, args|
      args.with_defaults(:zip_name => 'static_export')
      zip = args[:zip_name]
      zip += '.zip' unless zip.ends_with('.zip')
      sh %Q[zip --recursive --no-extra -j #{zip} #{@export_dir}]
      # TODO rescue zip
      invoke 'purge'
    end

  end
end
