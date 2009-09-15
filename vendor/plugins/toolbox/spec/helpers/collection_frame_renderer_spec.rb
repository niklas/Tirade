require File.dirname(__FILE__) + '/../spec_helper'

describe CollectionFrameRenderer do
  subject do
    5.times { Factory :document }
    @collection = Document.all
    CollectionFrameRenderer.new(@collection, helper)
  end
  before( :each ) do
    stubs_for_helper
  end

  it_should_behave_like 'every FrameRenderer'

  it "should add resource identifier and metadata to div" do
    html.should have_tag("div.frame.index.document[data]")
  end
end

