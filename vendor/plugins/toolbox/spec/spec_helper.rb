require File.expand_path(File.dirname(__FILE__) + "/../../../../spec/spec_helper")

def stubs_for_helper
  helper.stub!(:render).and_return("stubbed render call")
  helper.stub!(:human_name).and_return('Documents')
  helper.stub!(:resource_name).and_return('document')
  helper.stub!(:link_to_new).and_return('[New Link]')
  helper.stub!(:link_to_edit).and_return('[Edit Link]')
  helper.stub!(:link_to_destroy).and_return('[Destroy Link]')
  helper.stub!(:link_to_cancel).and_return('[Cancel Link]')
  helper.stub!(:link_to_ok).and_return('[OK Link]')
  helper.extend UtilityHelper
  helper.extend RjsHelper
end

def html
  subject.html
end

describe "every FrameRenderer", :shared => true do
  it "should render HTML successful" do
    lambda { html }.should_not raise_error
  end

  it "should render something" do
    helper.should_receive(:render).with(anything)
    html.should_not be_blank
  end

  it "should render a div.frame" do
    html.should have_tag('div.frame')
  end

  it "should present CSS classes" do
    css = subject.css
    css.should include('frame')
  end
end
