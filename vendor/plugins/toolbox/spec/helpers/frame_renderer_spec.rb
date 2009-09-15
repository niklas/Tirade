require File.dirname(__FILE__) + '/../spec_helper'

describe FrameRenderer do
  before( :each ) do
    stubs_for_helper
    @r = FrameRenderer.new(template)
  end
end

