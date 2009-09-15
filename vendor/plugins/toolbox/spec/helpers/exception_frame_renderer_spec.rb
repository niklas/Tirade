require File.dirname(__FILE__) + '/../spec_helper'

describe ExceptionFrameRenderer do
  before( :each ) do
    stubs_for_helper
    @exception = mock(Error)
    @r = ExceptionFrameRenderer.new(template)
  end
end

