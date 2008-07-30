require File.expand_path("#{File.dirname(__FILE__)}/../rails_spec_helper")

describe ActiveRecord::Migration::DesertMigration do
  attr_reader :fixture
  before do
    @fixture = Object.new
    fixture.extend ActiveRecord::Migration::DesertMigration
  end

  context "when plugin has an invalid name" do
    it "raises an error" do
      lambda do
        path_for_plugin("non_existent_plugin")
      end.should raise_error
    end
  end

  describe "#migrate_plugin" do
    it "migrates the particular plugin" do
      fake_plugin = "i am a plugin"
      stub(Desert::Manager).find_plugin("my_plugin") {fake_plugin}
      mock(Desert::PluginMigrations::Migrator).migrate_plugin(fake_plugin, 3)

      fixture.migrate_plugin("my_plugin", 3)
    end
  end

end
