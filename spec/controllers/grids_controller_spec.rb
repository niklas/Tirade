require File.dirname(__FILE__) + '/../spec_helper'

describe GridsController do

  #Delete these examples and add some real ones
  it "should use GridsController" do
    controller.should be_an_instance_of(GridsController)
  end


  describe "GET 'show'" do
    fixtures :users
    before(:each) do
      login_as :valid_user
      skip_lockdown
      @grid = Grid.new
      Grid.stub!(:find).and_return(@grid)
    end
    it "should be successful" do
      get 'show', :id => 1
      response.should be_success
    end
  end
end
