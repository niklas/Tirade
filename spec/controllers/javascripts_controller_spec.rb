require File.dirname(__FILE__) + '/../spec_helper'

describe JavascriptsController do

  #Delete these examples and add some real ones
  it "should use JavascriptsController" do
    controller.should be_an_instance_of(JavascriptsController)
  end


  describe "GET 'named_routes'" do
    it "should be successful" do
      get 'named_routes'
      response.should be_success
    end
  end
end
