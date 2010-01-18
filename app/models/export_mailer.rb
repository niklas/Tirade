class ExportMailer < ActionMailer::Base
  def zip(address, zip_path)
    recipients   address
    from         Settings.export_mail_address || %(Tirade <tirade+no-reply@lanpartei.de>)
    subject      "Your exported Site"
    body         nil
    sent_on      Time.now
    attachment   :content_type => "application/zip", :body => File.read(zip_path)
  end
end
