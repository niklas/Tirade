require "test/unit"

require "javascript_test_autotest"

class TestConfig < Test::Unit::TestCase
  def setup
    Object.const_set("RAILS_ROOT", File.dirname(__FILE__) + "/test_rails_app/") 
  end
  
  def test_load_config
    browsers = JavascriptTestAutotest::Config.get :browsers
    assert_not_nil(browsers, ":browsers not found in config #{JavascriptTestAutotest::Config.send(:configs)}")
    assert_not_nil(browsers["safari"])
    assert_not_nil(browsers["firefox"])
  end
end