begin
  [Page,Grid].each do |klass|
    ActiveRecord::Base.logger.info("Rebuilding tree structure for #{klass}")
    klass.rebuild!
  end
rescue Exception => e
  # yeah.,.. log it?
end
