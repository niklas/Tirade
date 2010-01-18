require 'fileutils'
require 'find'
module Tirade
module Exporting

  ArchivePath = File.join(RAILS_ROOT, 'public', 'exports')

  def check_directory
    unless File.directory? export_dir
      raise RuntimeError, "could not create temporary directory"
    end
  end

  def export_dir
    @export_dir ||= `mktemp -t -d`.chomp
  end

  def logfile
    # TODO timestamp in tmp
    @log ||= File.join(export_dir, 'export.log')
  end

  def log(message)
    STDERR.puts message if @verbose
  end

  def sh(command)
    log command
    system command
  end

  # Mirrors the whole Site to the filesystem
  def mirror
    check_directory

    log "Mirroring to #{export_dir}"
    command = %Q[wget --output-file=#{logfile} --directory-prefix=#{export_dir} --force-directories --no-host-directories --mirror #{@host}]
    command << %Q[ --header "Tirade-Exporting: true"]
    unless @locales.empty?
      locs = @locales.uniq.join(',')
      command << %Q[ --header "Tirade-Locales: #{locs}"]
      paths = (@locales + %w(images stylesheets themes javascripts upload flash )).uniq.join(',')
      command << %Q[ --include-directories=#{paths}]
    end
    sh command
    
    # Remove query params in file name (everything after a question mark)
    # to not confuse the static web server or caches/proxies
    log "Removing query params"
    Find.find(export_dir + '/') do |file|
      if file =~ /(.+)\?/
        clean = $1
        File.rename file, clean
      end
    end

    log "Applying theme"
    theme = Settings.public_theme
    FileUtils.mkdir_p "#{export_dir}/themes/#{theme}/"
    sh "rsync -a #{RAILS_ROOT}/themes/#{theme}/images #{export_dir}/themes/#{theme}/"
  end

  def syncto(target)
    log "Syncing to #{target}"
    sh "rsync -azqc --delete-after --rsh=ssh #{export_dir}/ #{target}"
  end

  def mailto(address)
    zip
    log "sending mail with attached zip to #{address}"
    ExportMailer.deliver_zip(address, zip)
  end

  # Zip the +export_dir+, return the filename.zip
  def zip
    return @zip if @zip.present?
    log "Zipping"
    @zip = `mktemp -t static_export_XXXXXXXXXX`.chomp + '.zip'
    sh %Q[cd #{export_dir} && zip -rXq #{zip} . -x \\*.log]
    @zip
  end

  # Purges the files of the exported Site
  def purge
    if @zip.present?
      log "Archiving zip to #{ArchivePath}"
      FileUtils.mkdir_p ArchivePath
      FileUtils.mv @zip, ArchivePath
    end
    log "Removing temp files"
    FileUtils.rm_rf export_dir
  end

end
end
