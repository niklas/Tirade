require File.dirname(__FILE__) + '/../../spec_helper'

describe Pages::LayoutController do

  #Delete these examples and add some real ones
  it "should use Pages::LayoutController" do
    controller.should be_an_instance_of(Pages::LayoutController)
  end


  describe "GET 'create'" do
    it "should be successful" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "should be successful" do
      get 'update'
      response.should be_success
    end
  end
end
