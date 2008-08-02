require File.dirname(__FILE__) + '/../spec_helper'

describe RolesController do
  describe "handling GET /Roles" do

    before(:each) do
      @role = mock_model(Role)
      Role.stub!(:find).and_return([@role])
    end
  
    def do_get
      get :index, :format => 'js'
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('/model/index')
    end
  
    it "should find all Roles" do
      Role.should_receive(:find).with(:all).and_return([@role])
      do_get
    end
  
    it "should assign the found Roles for the view" do
      do_get
      assigns[:roles].should == [@role]
    end
  end

  describe "handling GET /Roles/1" do

    before(:each) do
      @role = mock_model(Role)
      Role.stub!(:find).and_return(@role)
    end
  
    def do_get
      get :show, :id => "1", :format => 'js'
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('/model/show')
    end
  
    it "should find the Role requested" do
      Role.should_receive(:find).with("1").and_return(@role)
      do_get
    end
  
    it "should assign the found Role for the view" do
      do_get
      assigns[:role].should equal(@role)
    end
  end

  describe "handling GET /Roles/new" do

    before(:each) do
      @role = mock_model(Role)
      Role.stub!(:new).and_return(@role)
    end
  
    def do_get
      get :new, :format => 'js'
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('/model/new')
    end
  
    it "should create an new Role" do
      Role.should_receive(:new).and_return(@role)
      do_get
    end
  
    it "should not save the new Role" do
      @role.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new Role for the view" do
      do_get
      assigns[:role].should equal(@role)
    end
  end

  describe "handling GET /Roles/1/edit" do

    before(:each) do
      @role = mock_model(Role)
      Role.stub!(:find).and_return(@role)
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
      response.should render_template('/model/edit')
    end
  
    it "should find the Role requested" do
      Role.should_receive(:find).and_return(@role)
      do_get
    end
  
    it "should assign the found Role for the view" do
      do_get
      assigns[:role].should equal(@role)
    end
  end

  describe "handling POST /Roles" do

    before(:each) do
      @role = mock_model(Role, :to_param => "1")
      Role.stub!(:new).and_return(@role)
    end
    
    describe "with successful save" do
  
      def do_post
        @role.should_receive(:save).and_return(true)
        post :create, :Role => {}
      end
  
      it "should create a new Role" do
        Role.should_receive(:new).and_return(@role)
        do_post
      end

      it "should redirect to the new Role" do
        do_post
        response.should redirect_to(role_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @role.should_receive(:save).and_return(false)
        post :create, :Role => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('/model/new')
      end
      
    end
  end

  describe "handling PUT /Roles/1" do

    before(:each) do
      @role = mock_model(Role, :to_param => "1")
      Role.stub!(:find).and_return(@role)
    end
    
    describe "with successful update" do

      def do_put
        @role.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should (re)set the permission_ids, even if not supplied" do
        @role.should_receive(:update_attributes).with({'permission_ids' => []}).and_return(true)
        put :update, :id => "1"
      end

      it "should find the Role requested" do
        Role.should_receive(:find).with("1").and_return(@role)
        do_put
      end

      it "should update the found Role" do
        do_put
        assigns(:role).should equal(@role)
      end

      it "should assign the found Role for the view" do
        do_put
        assigns(:role).should equal(@role)
      end

      it "should redirect to the Role" do
        do_put
        response.should redirect_to(role_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @role.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('/model/edit')
      end

    end
  end

  describe "handling DELETE /Roles/1" do

    before(:each) do
      @role = mock_model(Role, :destroy => true)
      Role.stub!(:find).and_return(@role)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the Role requested" do
      Role.should_receive(:find).with("1").and_return(@role)
      do_delete
    end
  
    it "should call destroy on the found Role" do
      @role.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the Roles list" do
      do_delete
      response.should redirect_to(roles_url)
    end
  end
end
