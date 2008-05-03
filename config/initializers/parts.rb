require 'fileutils'

FileUtils.mkpath(Part::BasePath) unless File.directory?(Part::BasePath)
begin
  Part.recognize_new_files
rescue Exception => e
  # yeah...
end
