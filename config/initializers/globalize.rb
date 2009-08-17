I18n.default_locale = :en

I18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', '**', '*.{rb,yml}')]
require 'globalize/i18n/missing_translations_log_handler'
I18n.exception_handler = :missing_translations_log_handler
I18n.missing_translations_logger = Logger.new("#{RAILS_ROOT}/log/missing_translations.log")
