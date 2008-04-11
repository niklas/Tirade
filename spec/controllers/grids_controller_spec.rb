require File.dirname(__FILE__) + '/../spec_helper'

describe GridController do

  #Delete these examples and add some real ones
  it "should use GridController" do
    controller.should be_an_instance_of(GridController)
  end


  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end
end
