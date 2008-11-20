namespace :tirade do
  namespace :update do
    desc "Update all outdated slugs"
    task :slugs => :environment do
      Content.transaction do
        Content.without_timestamps do
          Content.all.each do |record|
            record.update_attribute :slug , record.title.sluggify
          end
        end
      end
    end
  end
end
