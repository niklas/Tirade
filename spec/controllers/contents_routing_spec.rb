require File.dirname(__FILE__) + '/../spec_helper'

describe ContentsController do
  describe "route generation" do

    it "should map { :controller => 'contents', :action => 'index' } to /contents" do
      route_for(:controller => "contents", :action => "index").should == "/contents"
    end
  
    it "should map { :controller => 'contents', :action => 'new' } to /contents/new" do
      route_for(:controller => "contents", :action => "new").should == "/contents/new"
    end
  
    it "should map { :controller => 'contents', :action => 'show', :id => 1 } to /contents/1" do
      route_for(:controller => "contents", :action => "show", :id => 1).should == "/contents/1"
    end
  
    it "should map { :controller => 'contents', :action => 'edit', :id => 1 } to /contents/1/edit" do
      route_for(:controller => "contents", :action => "edit", :id => 1).should == "/contents/1/edit"
    end
  
    it "should map { :controller => 'contents', :action => 'update', :id => 1} to /contents/1" do
      route_for(:controller => "contents", :action => "update", :id => 1).should == "/contents/1"
    end
  
    it "should map { :controller => 'contents', :action => 'destroy', :id => 1} to /contents/1" do
      route_for(:controller => "contents", :action => "destroy", :id => 1).should == "/contents/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'contents', action => 'index' } from GET /contents" do
      params_from(:get, "/contents").should == {:controller => "contents", :action => "index"}
    end
  
    it "should generate params { :controller => 'contents', action => 'new' } from GET /contents/new" do
      params_from(:get, "/contents/new").should == {:controller => "contents", :action => "new"}
    end
  
    it "should generate params { :controller => 'contents', action => 'create' } from POST /contents" do
      params_from(:post, "/contents").should == {:controller => "contents", :action => "create"}
    end
  
    it "should generate params { :controller => 'contents', action => 'show', id => '1' } from GET /contents/1" do
      params_from(:get, "/contents/1").should == {:controller => "contents", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'contents', action => 'edit', id => '1' } from GET /contents/1;edit" do
      params_from(:get, "/contents/1/edit").should == {:controller => "contents", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'contents', action => 'update', id => '1' } from PUT /contents/1" do
      params_from(:put, "/contents/1").should == {:controller => "contents", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'contents', action => 'destroy', id => '1' } from DELETE /contents/1" do
      params_from(:delete, "/contents/1").should == {:controller => "contents", :action => "destroy", :id => "1"}
    end
  end
end