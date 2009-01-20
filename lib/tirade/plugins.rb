module Tirade
  module Plugins
    def self.all_paths
      Dir.glob(File.join(RAILS_ROOT,'vendor','plugins','tirade_*'))
    end
    def self.all_names
      all_paths.map  {|path| File.basename path}
    end
  end
end
