module Tirade
  module Plugins
    class Plugin
      attr_reader :path
      def initialize(path)
        @path = path
      end
      def name
        File.basename path
      end
      def latest_migration_number
        File.basename(
          Dir.glob( File.join(path,'db','migrate','*rb') ).sort.last
        ).to_i
      end
    end
    def self.all
      Dir.glob(File.join(RAILS_ROOT,'vendor','plugins','tirade_*')).collect do |path|
        Plugin.new(path)
      end
    end
    def self.all_paths
      all.map(&:path)
    end
    def self.all_names
      all.map(&:name)
    end
  end
end
