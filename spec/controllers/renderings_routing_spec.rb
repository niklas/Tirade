require File.dirname(__FILE__) + '/../spec_helper'

describe RenderingsController do
  describe "route generation" do

    it "should map { :controller => 'renderings', :action => 'index' } to /renderings" do
      route_for(:controller => "renderings", :action => "index").should == "/renderings"
    end
  
    it "should map { :controller => 'renderings', :action => 'new' } to /renderings/new" do
      route_for(:controller => "renderings", :action => "new").should == "/renderings/new"
    end
  
    it "should map { :controller => 'renderings', :action => 'show', :id => 1 } to /renderings/1" do
      route_for(:controller => "renderings", :action => "show", :id => 1).should == "/renderings/1"
    end
  
    it "should map { :controller => 'renderings', :action => 'edit', :id => 1 } to /renderings/1/edit" do
      route_for(:controller => "renderings", :action => "edit", :id => 1).should == "/renderings/1/edit"
    end
  
    it "should map { :controller => 'renderings', :action => 'update', :id => 1} to /renderings/1" do
      route_for(:controller => "renderings", :action => "update", :id => 1).should == "/renderings/1"
    end
  
    it "should map { :controller => 'renderings', :action => 'destroy', :id => 1} to /renderings/1" do
      route_for(:controller => "renderings", :action => "destroy", :id => 1).should == "/renderings/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'renderings', action => 'index' } from GET /renderings" do
      params_from(:get, "/renderings").should == {:controller => "renderings", :action => "index"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'new' } from GET /renderings/new" do
      params_from(:get, "/renderings/new").should == {:controller => "renderings", :action => "new"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'create' } from POST /renderings" do
      params_from(:post, "/renderings").should == {:controller => "renderings", :action => "create"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'show', id => '1' } from GET /renderings/1" do
      params_from(:get, "/renderings/1").should == {:controller => "renderings", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'edit', id => '1' } from GET /renderings/1;edit" do
      params_from(:get, "/renderings/1/edit").should == {:controller => "renderings", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'update', id => '1' } from PUT /renderings/1" do
      params_from(:put, "/renderings/1").should == {:controller => "renderings", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'destroy', id => '1' } from DELETE /renderings/1" do
      params_from(:delete, "/renderings/1").should == {:controller => "renderings", :action => "destroy", :id => "1"}
    end
  end
end