require File.dirname(__FILE__) + '/../spec_helper'

describe RecordFrameRenderer do
  subject do
    @record = Factory :document
    RecordFrameRenderer.new(@record, helper)
  end
  before( :each ) do
    stubs_for_helper
  end
  it_should_behave_like 'every FrameRenderer'
end

