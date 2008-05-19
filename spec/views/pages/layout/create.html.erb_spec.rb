require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/pages/layout/create" do
  before(:each) do
    render 'pages/layout/create'
  end
  
  it "should render successfully" do
    response.should be_success
  end
end
