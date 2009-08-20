# This preloads the content types so that they are registered as Tirade::ActiveRecord::Content

APP_CONFIG[:content_types].each do |typ|
  typ.to_s.constantize
end if APP_CONFIG[:content_types]

