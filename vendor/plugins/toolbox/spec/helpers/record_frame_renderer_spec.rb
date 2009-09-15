require File.dirname(__FILE__) + '/../spec_helper'

describe RecordFrameRenderer do
  before( :each ) do
    stubs_for_helper
    @record = Factory :document
    @r = RecordFrameRenderer.new(@record, template)
  end
end

