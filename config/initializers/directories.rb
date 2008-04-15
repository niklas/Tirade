require 'fileutils'

FileUtils.mkpath(Part::BasePath) unless File.directory?(Part::BasePath)
