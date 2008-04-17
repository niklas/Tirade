require File.dirname(__FILE__) + '/../spec_helper'

describe Image do
  before(:each) do
    @image = Image.new
  end

  it "should be valid" do
    @image.should be_valid
  end
  
  it "should be intergrated with paperclip" do
    @image.should respond_to :image
  end
end
