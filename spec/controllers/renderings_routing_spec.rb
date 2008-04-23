require File.dirname(__FILE__) + '/../spec_helper'

describe RenderingsController do
  describe "route generation" do

    it "should map { :controller => 'renderings', :action => 'index' } to /manage/renderings" do
      route_for(:controller => "renderings", :action => "index").should == "/manage/renderings"
    end
  
    it "should map { :controller => 'renderings', :action => 'new' } to /manage/renderings/new" do
      route_for(:controller => "renderings", :action => "new").should == "/manage/renderings/new"
    end
  
    it "should map { :controller => 'renderings', :action => 'show', :id => 1 } to /manage/renderings/1" do
      route_for(:controller => "renderings", :action => "show", :id => 1).should == "/manage/renderings/1"
    end
  
    it "should map { :controller => 'renderings', :action => 'edit', :id => 1 } to /manage/renderings/1/edit" do
      route_for(:controller => "renderings", :action => "edit", :id => 1).should == "/manage/renderings/1/edit"
    end
  
    it "should map { :controller => 'renderings', :action => 'update', :id => 1} to /manage/renderings/1" do
      route_for(:controller => "renderings", :action => "update", :id => 1).should == "/manage/renderings/1"
    end
  
    it "should map { :controller => 'renderings', :action => 'destroy', :id => 1} to /manage/renderings/1" do
      route_for(:controller => "renderings", :action => "destroy", :id => 1).should == "/manage/renderings/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'renderings', action => 'index' } from GET /manage/renderings" do
      params_from(:get, "/manage/renderings").should == {:controller => "renderings", :action => "index"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'new' } from GET /manage/renderings/new" do
      params_from(:get, "/manage/renderings/new").should == {:controller => "renderings", :action => "new"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'create' } from POST /manage/renderings" do
      params_from(:post, "/manage/renderings").should == {:controller => "renderings", :action => "create"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'show', id => '1' } from GET /manage/renderings/1" do
      params_from(:get, "/manage/renderings/1").should == {:controller => "renderings", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'edit', id => '1' } from GET /manage/renderings/1;edit" do
      params_from(:get, "/manage/renderings/1/edit").should == {:controller => "renderings", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'update', id => '1' } from PUT /manage/renderings/1" do
      params_from(:put, "/manage/renderings/1").should == {:controller => "renderings", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'renderings', action => 'destroy', id => '1' } from DELETE /manage/renderings/1" do
      params_from(:delete, "/manage/renderings/1").should == {:controller => "renderings", :action => "destroy", :id => "1"}
    end
  end
end
