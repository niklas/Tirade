require File.expand_path(File.dirname(__FILE__) + "/../../../../spec/spec_helper")

def stubs_for_helper
  helper.stub!(:render).and_return("stubbed render call")
  helper.stub!(:human_name).and_return('Documents')
  helper.stub!(:resource_name).and_return('document')
end
