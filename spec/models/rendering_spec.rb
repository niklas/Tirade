require File.dirname(__FILE__) + '/../spec_helper'

describe Rendering do
  before(:each) do
    @rendering = Rendering.new
  end

  it "should be valid" do
    @rendering.should be_valid
  end
end
