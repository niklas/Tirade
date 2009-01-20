# register all used filters
Dir.glob(File.join(RAILS_ROOT,'app','filters','*.rb')).map do |path|
  File.basename path
end.map do |filename|
  filename.gsub(/\.rb$/,'')
end.map(&:classify).map(&:constantize).each do |mod|
  begin
    Liquid::Template.register_filter(mod)
  rescue Liquid::ArgumentError => e
    logger.info(e.message)
  end
end
