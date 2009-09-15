require File.dirname(__FILE__) + '/../spec_helper'

describe EditRecordFrameRenderer, 'for an existing document' do
  subject do
    @record = Factory :document
    EditRecordFrameRenderer.new(@record, helper)
  end
  before( :each ) do
    stubs_for_helper
  end
  it_should_behave_like 'every FrameRenderer'

  it "should add resource identifier and metadata to div" do
    html.should have_tag("div.frame.document.document_#{@record.id}[data]")
  end
end

describe EditRecordFrameRenderer, 'for a new document' do
  subject do
    @record = Factory.build :document
    EditRecordFrameRenderer.new(@record, helper)
  end
  before( :each ) do
    stubs_for_helper
  end
  it_should_behave_like 'every FrameRenderer'

  it "should add resource identifier and metadata to div" do
    html.should have_tag("div.frame.document.new_document[data]")
  end
end
