require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Paperclipping do
  before(:each) do
    @valid_attributes = {
      :asset_id => 1,
      :content_id => 1,
      :position => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Paperclipping.create!(@valid_attributes)
  end
end
