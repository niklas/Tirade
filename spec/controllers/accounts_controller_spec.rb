require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController, "routes" do
  it "should map {:controller => 'accounts', :action => 'show'} to /en/manage/account" do
    route_for(:controller => 'accounts', :action => 'show', :locale => 'en').should == '/en/manage/account'
  end
  it "should map {:controller => 'accounts', :action => 'edit'} to /en/manage/account/edit" do
    route_for(:controller => 'accounts', :action => 'edit', :locale => 'en').should == '/en/manage/account/edit'
  end
end

describe AccountsController, "in Toolbox" do
  before( :each ) do
    login_standard
  end

  describe "requesting show" do
    def do_request
      get :show, :format => 'js'
    end

    it "should be successful" do
      do_request
      response.should be_success
    end
  end
end
