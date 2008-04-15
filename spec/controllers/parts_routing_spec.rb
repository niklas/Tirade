require File.dirname(__FILE__) + '/../spec_helper'

describe PartsController do
  describe "route generation" do

    it "should map { :controller => 'parts', :action => 'index' } to /parts" do
      route_for(:controller => "parts", :action => "index").should == "/parts"
    end
  
    it "should map { :controller => 'parts', :action => 'new' } to /parts/new" do
      route_for(:controller => "parts", :action => "new").should == "/parts/new"
    end
  
    it "should map { :controller => 'parts', :action => 'show', :id => 1 } to /parts/1" do
      route_for(:controller => "parts", :action => "show", :id => 1).should == "/parts/1"
    end
  
    it "should map { :controller => 'parts', :action => 'edit', :id => 1 } to /parts/1/edit" do
      route_for(:controller => "parts", :action => "edit", :id => 1).should == "/parts/1/edit"
    end
  
    it "should map { :controller => 'parts', :action => 'update', :id => 1} to /parts/1" do
      route_for(:controller => "parts", :action => "update", :id => 1).should == "/parts/1"
    end
  
    it "should map { :controller => 'parts', :action => 'destroy', :id => 1} to /parts/1" do
      route_for(:controller => "parts", :action => "destroy", :id => 1).should == "/parts/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'parts', action => 'index' } from GET /parts" do
      params_from(:get, "/parts").should == {:controller => "parts", :action => "index"}
    end
  
    it "should generate params { :controller => 'parts', action => 'new' } from GET /parts/new" do
      params_from(:get, "/parts/new").should == {:controller => "parts", :action => "new"}
    end
  
    it "should generate params { :controller => 'parts', action => 'create' } from POST /parts" do
      params_from(:post, "/parts").should == {:controller => "parts", :action => "create"}
    end
  
    it "should generate params { :controller => 'parts', action => 'show', id => '1' } from GET /parts/1" do
      params_from(:get, "/parts/1").should == {:controller => "parts", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'parts', action => 'edit', id => '1' } from GET /parts/1;edit" do
      params_from(:get, "/parts/1/edit").should == {:controller => "parts", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'parts', action => 'update', id => '1' } from PUT /parts/1" do
      params_from(:put, "/parts/1").should == {:controller => "parts", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'parts', action => 'destroy', id => '1' } from DELETE /parts/1" do
      params_from(:delete, "/parts/1").should == {:controller => "parts", :action => "destroy", :id => "1"}
    end
  end
end