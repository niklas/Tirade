require 'fileutils'
require 'find'
namespace :tirade do
  namespace :export do

    desc "Purges the exported Site"
    task :purge do
      FileUtils.rm_rf 'localhost'
    end

    desc "Mirrors the whole Site to the filesystem"
    task :mirror => [:purge] do
      sh %q[wget --output-file=export.log --force-directories --mirror http://localhost]
    end

    task :mirror_theme do
      sh "rsync -a /home/www/tirade/shared/themes/gsmk/images localhost/themes/gsmk/"
    end

    desc "Cleans up the exported Site"
    task :cleanup do
      # Remove query params in file name (everything after a question mark)
      Find.find('localhost/') do |file|
        if file =~ /(.+)\?/
          clean = $1
          File.rename file, clean
        end
      end
    end


  end
end
