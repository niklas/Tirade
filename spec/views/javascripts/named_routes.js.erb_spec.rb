require File.dirname(__FILE__) + '/../../spec_helper'

describe "/javascripts/named_routes" do
  before(:each) do
    render 'javascripts/named_routes.js.erb'
  end
  
  it "should define the function get_url" do
    response.should have_text(%r~get_url\(~)
  end
end
