require File.dirname(__FILE__) + '/../../spec_helper'

describe "/contents/index.html.erb" do
  include ContentsHelper
  
  before(:each) do
    assigns[:contents] = [Factory(:content), Factory(:content)]
  end

  it "should render list of contents" do
    render "/contents/index.html.erb"
    response.should be_success
  end
end

