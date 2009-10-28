class StaticExportRsyncJob < Struct.new(:host)
  include StaticExport

  # Publish the static export to given host
  def perform
    mirror
    # TODO load hosts from anywhere, including target dir?
    # TODO actually do the rsync, s/puts/sh
    puts %Q[rsync -avz #{@export_dir} #{host}:/var/www]
    purge
  end
end
