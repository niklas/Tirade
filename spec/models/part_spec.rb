require File.dirname(__FILE__) + '/../spec_helper'

describe Part do
  before(:each) do
    @part = Part.new
  end

  it "should not be valid" do
    @part.should_not be_valid
  end

  describe ', setting a name and filename' do
    before(:each) do
      @part.name = 'General Preview'
      @part.filename = 'general_preview'
    end
    it "should be valid" do
      @part.should be_valid
    end
    it "should have correct filename with extention" do
      @part.filename_with_extention.should == 'general_preview.html.erb'
    end
    it "should habe correct fullpath" do
      @part.fullpath.should match(%r~app/views/parts/stock/general_preview.html.erb~)
    end
    it "should write its rhtml to a file" do
      File.stub!(:open).with(any_args()).and_return(true)
      File.should_receive(:open).with(@part.fullpath,'w')
      @part.save
    end
  end

  describe ', setting a name and filename with spaces' do
    before(:each) do
      @part.name = 'Another Preview'
      @part.filename = 'i have spaces'
    end
    it "should be valid" do
      @part.should_not be_valid
      @part.should have_at_least(1).errors_on(:filename)
    end
  end

end
