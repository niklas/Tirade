namespace :tirade do
  namespace :update do
    desc "Update all outdated slugs"
    task :slugs => :environment do
      Tirade::ActiveRecord::Content.classes.each do |content_class|
        next unless content_class.column_names.include? 'slug'
        content_class.logger.info "updating slugs"
        content_class.transaction do
          content_class.without_timestamps do
            content_class.all.each do |record|
              unless record.update_attributes :slug => record.title.andand.sluggify
                puts "could not save #{record.inspect} (#{record.errors.full_messages.join(',')})"
              end
            end
          end
        end
      end
    end
  end
end
