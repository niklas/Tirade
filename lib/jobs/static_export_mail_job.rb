class StaticExportMailJob < Struct.new(:email)
  include StaticExport

  # Send a static export to the given email address
  def perform
    mirror
    zip = `mktemp -t static_export_XXXXXXXXXX`.chomp + '.zip'
    sh %Q[cd #{export_dir} && zip -rXq #{zip} .]
    # TODO send zip to #email per SMTP
    purge
  end
end
