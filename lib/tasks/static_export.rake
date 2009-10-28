require 'fileutils'
require 'find'
namespace :tirade do
  namespace :export do
    desc "Send a static export to the given email address"
    task :mail, [:email] do |task, args|
      StaticExportMailJob.new(args.email).perform
    end

    desc "Publish the static export to given host"
    task :publish, [:host] do |task, args|
      StaticExportRsyncJob.new(args.host).perform
    end

  end
end
