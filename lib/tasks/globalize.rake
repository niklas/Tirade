namespace :tirade do
  namespace :locales do
    desc <<-EODESC
      Initialize the given locale with the data already saved in the real content types.
    EODESC
    task :init, [:locale] => [:environment] do |task, args|
      locale = args.locale
      if locale.blank?
        STDERR.puts "please give a locale to initialize"
        exit
      end
      I18n.locale = locale = locale.to_sym
      Tirade::ActiveRecord::Content.classes.each do |klass|
        next unless klass.respond_to?(:globalize_options)
        STDERR.puts "Initializing locale #{locale} for #{klass.name}"
        klass.without_timestamps do
          klass.all.each do |record|
            unless record.translated_locales.include?(locale)
              record.update_attributes record.attributes
            end
          end
        end
      end
    end
  end
end
