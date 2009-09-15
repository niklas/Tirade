require File.dirname(__FILE__) + '/../spec_helper'

describe ExceptionFrameRenderer do
  subject { ExceptionFrameRenderer.new(@exception, helper) }
  before( :each ) do
    stubs_for_helper
    @exception = mock(Exception)
  end

  it_should_behave_like 'every FrameRenderer'

  it "should add class 'error' to div" do
    html.should have_tag('div.frame.error[data]')
  end
end

