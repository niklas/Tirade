require 'fileutils'

FileUtils.mkpath(Part::BasePath) unless File.directory?(Part::BasePath)
Part.recognize_new_files
