require File.dirname(__FILE__) + '/../../spec_helper'

describe Rendering::GridHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should include the Rendering::GridHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(Rendering::GridHelper)
  end
  
end
