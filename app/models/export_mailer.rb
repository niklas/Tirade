class ExportMailer < ActionMailer::Base
  default_url_options[:host] = SITE_URL
  def zip(address, zip_path)
    recipients   address
    from         Settings.export_mail_address || %(Tirade <tirade+no-reply@lanpartei.de>)
    subject      "Your exported Site"
    body         :zip_path => zip_path
    sent_on      Time.now
#    attachment   :content_type => "application/zip", :body => File.read(zip_path)
  end
end
