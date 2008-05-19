require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/pages/layout/update" do
  before(:each) do
    render 'pages/layout/update'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should be_success
  end
end
