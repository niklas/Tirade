require 'fileutils'
require 'find'
module StaticExport

  private
  def check_directory
    unless File.directory? export_dir
      raise RuntimeError, "could not create temporary directory"
    end
  end

  def export_dir
    @export_dir ||= `mktemp -t -d`.chomp
  end

  def log
    @log ||= File.join(export_dir, 'export.log')
  end

  # Mirrors the whole Site to the filesystem
  def mirror
    check_directory
    sh %Q[wget --output-file=#{log} --directory-prefix=#{export_dir} --force-directories --no-host-directories --mirror http://localhost]
    theme = Settings.public_theme
    directory "#{export_dir}/themes/#{theme}/"
    
    # Remove query params in file name (everything after a question mark)
    # to not confuse the static web server or caches/proxies
    Find.find(export_dir + '/') do |file|
      if file =~ /(.+)\?/
        clean = $1
        File.rename file, clean
      end
    end

    sh "rsync -a #{RAILS_ROOT}/themes/#{theme}/images #{export_dir}/themes/#{theme}/"
  end

  # Purges the files of the exported Site
  def purge
    FileUtils.rm_rf export_dir
  end
end
