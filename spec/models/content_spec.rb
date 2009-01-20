require File.dirname(__FILE__) + '/../spec_helper'

describe Content do
  before(:each) do
    @content = Content.new
  end

  it "should not be valid" do
    @content.should_not be_valid
  end

  it "should know about its owner"

  describe "with a title" do
    before(:each) do
      @content.title = "Some Title"
    end
    it do
      @content.should be_valid
    end
  end
end

describe 'The Love letter' do
  fixtures :contents
  before(:each) do
    @love_letter = contents(:love_letter)
  end
  it "should be a Document" do
    @love_letter.should be_an_instance_of(Document)
  end
end
