require File.dirname(__FILE__) + '/../spec_helper'

describe ContentsController do
  describe "handling GET /contents" do

    before(:each) do
      @content = mock_model(Content)
      Content.stub!(:find).and_return([@content])
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all contents" do
      Content.should_receive(:find).with(:all).and_return([@content])
      do_get
    end
  
    it "should assign the found contents for the view" do
      do_get
      assigns[:contents].should == [@content]
    end
  end

  describe "handling GET /contents.xml" do

    before(:each) do
      @content = mock_model(Content, :to_xml => "XML")
      Content.stub!(:find).and_return(@content)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all contents" do
      Content.should_receive(:find).with(:all).and_return([@content])
      do_get
    end
  
    it "should render the found contents as xml" do
      @content.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /contents/1" do

    before(:each) do
      @content = mock_model(Content)
      Content.stub!(:find).and_return(@content)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the content requested" do
      Content.should_receive(:find).with("1").and_return(@content)
      do_get
    end
  
    it "should assign the found content for the view" do
      do_get
      assigns[:content].should equal(@content)
    end
  end

  describe "handling GET /contents/1.xml" do

    before(:each) do
      @content = mock_model(Content, :to_xml => "XML")
      Content.stub!(:find).and_return(@content)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the content requested" do
      Content.should_receive(:find).with("1").and_return(@content)
      do_get
    end
  
    it "should render the found content as xml" do
      @content.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /contents/new" do

    before(:each) do
      @content = mock_model(Content)
      Content.stub!(:new).and_return(@content)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new content" do
      Content.should_receive(:new).and_return(@content)
      do_get
    end
  
    it "should not save the new content" do
      @content.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new content for the view" do
      do_get
      assigns[:content].should equal(@content)
    end
  end

  describe "handling GET /contents/1/edit" do

    before(:each) do
      @content = mock_model(Content)
      Content.stub!(:find).and_return(@content)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the content requested" do
      Content.should_receive(:find).and_return(@content)
      do_get
    end
  
    it "should assign the found Content for the view" do
      do_get
      assigns[:content].should equal(@content)
    end
  end

  describe "handling POST /contents" do

    before(:each) do
      @content = mock_model(Content, :to_param => "1")
      Content.stub!(:new).and_return(@content)
    end
    
    describe "with successful save" do
  
      def do_post
        @content.should_receive(:save).and_return(true)
        post :create, :content => {}
      end
  
      it "should create a new content" do
        Content.should_receive(:new).with({}).and_return(@content)
        do_post
      end

      it "should redirect to the new content" do
        do_post
        response.should redirect_to(content_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @content.should_receive(:save).and_return(false)
        post :create, :content => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /contents/1" do

    before(:each) do
      @content = mock_model(Content, :to_param => "1")
      Content.stub!(:find).and_return(@content)
    end
    
    describe "with successful update" do

      def do_put
        @content.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the content requested" do
        Content.should_receive(:find).with("1").and_return(@content)
        do_put
      end

      it "should update the found content" do
        do_put
        assigns(:content).should equal(@content)
      end

      it "should assign the found content for the view" do
        do_put
        assigns(:content).should equal(@content)
      end

      it "should redirect to the content" do
        do_put
        response.should redirect_to(content_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @content.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /contents/1" do

    before(:each) do
      @content = mock_model(Content, :destroy => true)
      Content.stub!(:find).and_return(@content)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the content requested" do
      Content.should_receive(:find).with("1").and_return(@content)
      do_delete
    end
  
    it "should call destroy on the found content" do
      @content.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the contents list" do
      do_delete
      response.should redirect_to(contents_url)
    end
  end
end