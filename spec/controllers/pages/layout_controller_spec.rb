require File.dirname(__FILE__) + '/../../spec_helper'

describe Pages::LayoutController do
  fixtures :all

  before do
    @page = pages(:main)
  end

  #Delete these examples and add some real ones
  it "should use Pages::LayoutController" do
    controller.should be_an_instance_of(Pages::LayoutController)
  end


  describe "GET 'create'" do
    it "should be successful" do
      Page.should_receive(:find).with("1").and_return(@page)
      get 'create', :page_id => 1
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "should be successful" do
      Page.should_receive(:find).with("1").and_return(@page)
      get 'create', :page_id => 1
      response.should be_success
    end
  end
end
