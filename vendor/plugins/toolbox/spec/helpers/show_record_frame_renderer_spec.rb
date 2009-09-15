require File.dirname(__FILE__) + '/../spec_helper'

describe ShowRecordFrameRenderer do
  subject do
    @record = Factory :document
    ShowRecordFrameRenderer.new(@record, helper)
  end
  before( :each ) do
    stubs_for_helper
  end
  it_should_behave_like 'every FrameRenderer'

  it "should add resource identifier and metadata to div" do
    html.should have_tag("div.frame.document.document_#{@record.id}[data]")
  end
end

