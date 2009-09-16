require File.dirname(__FILE__) + '/../spec_helper'


describe FrameRenderer do
  subject { FrameRenderer.new(helper) }
  before( :each ) do
    stubs_for_helper
  end
  it_should_behave_like 'every FrameRenderer'

end

