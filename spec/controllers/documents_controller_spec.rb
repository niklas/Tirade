require File.dirname(__FILE__) + '/../spec_helper'

# This is one of the automatically detected Controller, so we have to define it here
class DocumentsController < ManageResourceController; end

describe DocumentsController do
  before( :each ) do
    login_as :quentin
    Document.destroy_all
    @document = Factory.create(:document)
    @documents = [@document]
    5.times { @documents << Factory.create(:document) }
  end

  it "should be a ManageResourceController" do
    controller.should be_a(ManageResourceController)
  end

  it "should manage Documents" do
    controller.send(:model).should == Document
  end

  it "should have some Documents provided" do
    Document.should have_at_least(6).records
  end

  describe "route recognition" do

    it "should generate params { :controller => 'documents', action => 'index' } from GET /manage/documents" do
      params_from(:get, "/manage/documents").should == {:controller => "documents", :action => "index"}
    end
  
    it "should generate params { :controller => 'documents', action => 'new' } from GET /manage/documents/new" do
      params_from(:get, "/manage/documents/new").should == {:controller => "documents", :action => "new"}
    end
  
    it "should generate params { :controller => 'documents', action => 'create' } from POST /manage/documents" do
      params_from(:post, "/manage/documents").should == {:controller => "documents", :action => "create"}
    end
  
    it "should generate params { :controller => 'documents', action => 'show', id => '1' } from GET /manage/documents/1" do
      params_from(:get, "/manage/documents/1").should == {:controller => "documents", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'documents', action => 'edit', id => '1' } from GET /manage/documents/1;edit" do
      params_from(:get, "/manage/documents/1/edit").should == {:controller => "documents", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'documents', action => 'update', id => '1' } from PUT /manage/documents/1" do
      params_from(:put, "/manage/documents/1").should == {:controller => "documents", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'documents', action => 'destroy', id => '1' } from DELETE /manage/documents/1" do
      params_from(:delete, "/manage/documents/1").should == {:controller => "documents", :action => "destroy", :id => "1"}
    end
    
  end

  describe "route generation" do

    it "should map { :controller => 'documents', :action => 'index' } to /manage/documents" do
      route_for(:controller => "documents", :action => "index").should == "/manage/documents"
    end
  
    it "should map { :controller => 'documents', :action => 'new' } to /manage/documents/new" do
      route_for(:controller => "documents", :action => "new").should == "/manage/documents/new"
    end
  
    it "should map { :controller => 'documents', :action => 'show', :id => 1 } to /manage/documents/1" do
      route_for(:controller => "documents", :action => "show", :id => '1').should == "/manage/documents/1"
    end
  
    it "should map { :controller => 'documents', :action => 'edit', :id => 1 } to /manage/documents/1/edit" do
      route_for(:controller => "documents", :action => "edit", :id => '1').should == "/manage/documents/1/edit"
    end

    it "should map document_path(document) to /manage/documents/:id" do
      document_path(@document).should =~ %r~^/manage/documents/document-\d+~ 
    end
    
  end

  describe "by AJAX" do

    describe "get /index without any params" do

      it "should succeed" do
        get :index, :format => 'js'
        response.should be_success
      end

      it "should set assigns" do
        get :index, :format => 'js'
        assigns[:collection].should_not be_blank
        assigns[:documents].should_not be_blank
      end

      it "should render a list" do
        get :index, :format => 'js'
        response.should render_template('_list.html.erb')
      end

      it "should push the list into toolbox" do
        get :index, :format => 'js'
        response.should push_frame
      end

      it "should set the toolbox header" do
        get :index, :format => 'js'
        response.should set_toolbox_header('Documents')
      end

    end
    
    describe "get /new" do

      before( :each ) do
        get :new, :format => 'js'
      end

      it "should succeed" do
        response.should be_success
      end

      it "should render the contents form (document has no own yet )" do
        response.should render_template('contents/_form.html.erb')
      end

    end

    describe "get /show" do

      before( :each ) do
        get :show, :id => @document.to_param, :format => 'js'
      end

      it "should succeed" do
        response.should be_success
      end

      it "should render show partial" do
        response.should render_template('contents/_show.html.erb')
      end

    end
    
    describe "get /edit" do

      before( :each ) do
        get :edit, :id => @document.to_param, :format => 'js'
      end

      it "should succeed" do
        response.should be_success
      end

      it "should render the contents form (document has no own yet )" do
        response.should render_template('contents/_form.html.erb')
      end

    end

  end

end
