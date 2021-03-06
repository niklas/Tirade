require File.dirname(__FILE__) + '/../spec_helper'

describe RenderingsController do
  before(:each) do
    login_with_group :admin_renderings
  end
    
  describe "handling GET /renderings" do

    before(:each) do
      @rendering = mock_model(Rendering)
      Rendering.stub!(:find).and_return([@rendering])
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
  
  end

  describe "handling GET /renderings/1" do

    before(:each) do
      login_with_group :admin_renderings
      @rendering = mock_model(Rendering)
      Rendering.stub!(:find).and_return(@rendering)
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
  
    it "should find the rendering requested" do
      Rendering.should_receive(:find).with("1").and_return(@rendering)
      do_get
    end
  
    it "should assign the found rendering for the view" do
      do_get
      assigns[:rendering].should equal(@rendering)
    end
  end

  describe "handling GET /renderings/new" do

    before(:each) do
      @rendering = mock_model(Rendering)
      Rendering.stub!(:new).and_return(@rendering)
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
  
    it "should create an new rendering" do
      Rendering.should_receive(:new).and_return(@rendering)
      do_get
    end
  
    it "should not save the new rendering" do
      @rendering.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new rendering for the view" do
      do_get
      assigns[:rendering].should equal(@rendering)
    end
  end

  describe "handling GET /renderings/1/edit" do

    before(:each) do
      @rendering = mock_model(Rendering)
      Rendering.stub!(:find).and_return(@rendering)
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
  
    it "should find the rendering requested" do
      Rendering.should_receive(:find).and_return(@rendering)
      do_get
    end
  
    it "should assign the found Rendering for the view" do
      do_get
      assigns[:rendering].should equal(@rendering)
    end
  end

  describe "handling POST /renderings" do

    before(:each) do
      @rendering = mock_model(Rendering, :to_param => "1")
      Rendering.stub!(:new).and_return(@rendering)
    end
    
    describe "with successful save" do
  
      def do_post
        @rendering.should_receive(:save).and_return(true)
        post :create, :rendering => {}
      end
  
      it "should create a new rendering" do
        Rendering.should_receive(:new).with({}).and_return(@rendering)
        do_post
      end

      it "should redirect to the new rendering" do
        do_post
        response.should redirect_to(rendering_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @rendering.should_receive(:save).and_return(false)
        post :create, :rendering => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /renderings/1" do

    before(:each) do
      @rendering = mock_model(Rendering, :to_param => "1")
      Rendering.stub!(:find).and_return(@rendering)
    end
    
    describe "with successful update" do

      def do_put
        @rendering.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the rendering requested" do
        Rendering.should_receive(:find).with("1").and_return(@rendering)
        do_put
      end

      it "should update the found rendering" do
        do_put
        assigns(:rendering).should equal(@rendering)
      end

      it "should assign the found rendering for the view" do
        do_put
        assigns(:rendering).should equal(@rendering)
      end

      it "should redirect to the rendering" do
        do_put
        response.should redirect_to(rendering_path(@rendering))
      end

    end
    
    describe "with failed update" do

      def do_put
        @rendering.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /renderings/1" do

    before(:each) do
      @rendering = mock_model(Rendering, :destroy => true, :page => nil, :table_name => 'renderings')
      Rendering.stub!(:find).and_return(@rendering)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the rendering requested" do
      Rendering.should_receive(:find).with("1").and_return(@rendering)
      do_delete
    end
  
    it "should call destroy on the found rendering" do
      @rendering.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the list of renderings" do
      do_delete
      response.should redirect_to('/en/manage/renderings')
    end
  end
end
