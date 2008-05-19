require 'fileutils'

FileUtils.mkpath(Part::BasePath) unless File.directory?(Part::BasePath)
begin
  Part.sync!
rescue Exception => e
  # yeah...
end
