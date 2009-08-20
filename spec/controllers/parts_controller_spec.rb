require File.dirname(__FILE__) + '/../spec_helper'

describe PartsController do
  before(:each) do
    login_with_group :admin_parts
    login_standard
    Part.stub!(:sync!).and_return(true)
  end

  describe "handling GET /parts" do

    before(:each) do
      @part = Factory(:part)
      Part.stub!(:find).and_return([@part])
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
  
    it "should assign the found parts for the view" do
      do_get
      assigns[:parts].should == [@part]
    end
  end

  describe "handling GET /parts/1" do

    before(:each) do
      @part = Factory(:part)
      Part.stub!(:find).and_return(@part)
    end
  
    def do_get
      get :show, :id => @part.id
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the part requested" do
      Part.should_receive(:find).with(@part.id.to_s).and_return(@part)
      do_get
    end
  
    it "should assign the found part for the view" do
      do_get
      assigns[:part].should equal(@part)
    end
  end


  describe "handling GET /parts/new" do

    before(:each) do
      @part = Factory.build(:part)
      Part.stub!(:new).and_return(@part)
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
  
    it "should create an new part" do
      Part.should_receive(:new).and_return(@part)
      do_get
    end
  
    it "should not save the new part" do
      @part.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new part for the view" do
      do_get
      assigns[:part].should equal(@part)
    end
  end

  describe "handling GET /parts/1/edit" do

    before(:each) do
      @part = Factory(:part)
      Part.stub!(:find).and_return(@part)
    end
  
    def do_get
      get :edit, :id => @part.id
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the part requested" do
      Part.should_receive(:find).and_return(@part)
      do_get
    end
  
    it "should assign the found Part for the view" do
      do_get
      assigns[:part].should equal(@part)
    end
  end

  describe "handling POST /parts" do

    before(:each) do
      @part = Factory.build(:part)
      @part.stub!(:id).and_return(2342)
      Part.stub!(:new).and_return(@part)
    end
    
    describe "with successful save" do
  
      def do_post
        @part.should_receive(:save).and_return(true)
        post :create, :part => {}
      end
  
      it "should create a new part" do
        Part.should_receive(:new).with({}).and_return(@part)
        do_post
      end

      it "should redirect to the new part" do
        do_post
        response.should redirect_to(part_url(@part))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @part.should_receive(:save).and_return(false)
        post :create, :part => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /parts/1" do

    before(:each) do
      @part = Factory(:part)
      Part.stub!(:find).and_return(@part)
    end
    
    describe "with successful update" do

      def do_put
        @part.should_receive(:update_attributes).and_return(true)
        put :update, :id => @part.id
      end

      it "should find the part requested" do
        Part.should_receive(:find).with(@part.id.to_s).and_return(@part)
        do_put
      end

      it "should update the found part" do
        do_put
        assigns(:part).should equal(@part)
      end

      it "should assign the found part for the view" do
        do_put
        assigns(:part).should equal(@part)
      end

      it "should redirect to the part" do
        do_put
        response.should redirect_to(part_url(@part))
      end

    end
    
    describe "with failed update" do

      def do_put
        @part.should_receive(:update_attributes).and_return(false)
        put :update, :id => @part.id
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /parts/1" do

    before(:each) do
      @part = Factory(:part)
      Part.stub!(:find).and_return(@part)
    end
  
    def do_delete
      delete :destroy, :id => @part.id
    end

    it "should find the part requested" do
      Part.should_receive(:find).with(@part.id.to_s).and_return(@part)
      do_delete
    end
  
    it "should call destroy on the found part" do
      @part.should_receive(:destroy)
      do_delete
    end
  
    #it "should redirect to the parts list" do
    #  do_delete
    #  response.should redirect_to(parts_url)
    #end
  end
end
