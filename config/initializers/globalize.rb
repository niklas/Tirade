I18n.locale = :en

require 'globalize/i18n/missing_translations_log_handler'
I18n.exception_handler = :missing_translations_log_handler
logger = Logger.new("#{RAILS_ROOT}/log/missing_translations.log")
I18n.missing_translations_logger = logger
