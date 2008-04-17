require File.dirname(__FILE__) + '/../spec_helper'

describe Content do
  before(:each) do
    @content = Content.new
  end

  it "should be valid" do
    @content.should be_valid
  end
end
