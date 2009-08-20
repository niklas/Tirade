require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Part::PluginController do
  before :each do
    login_with_group :admin_parts
    login_standard
  end

  describe "route generation" do
    it "should map { :action => 'show', :id => 'extra', :part_id => 23} to /manage/parts/23/plugin/extra" do
      route_for(:controller => 'part/plugin', :action => 'show', :id => 'extra', :part_id => '23').should == 
        "/manage/parts/23/plugin/extra"
    end
  end

  describe "route recognition" do
    it "should generate params { :action => 'show', :id => 'extra', :part_id => 23} from GET /manage/parts/23/plugin/extra" do
      params_from(:get, '/manage/parts/23/plugin/extra').should == {
        :controller => 'part/plugin', :action => 'show',
        :part_id => "23", :id => 'extra'
      }
    end
    it "should generate params { :action => 'show', :id => 'extra', :part_id => 23} from DELETE /manage/parts/23/plugin/42" do
      params_from(:delete, '/manage/parts/23/plugin/42').should == {
        :controller => 'part/plugin', :action => 'destroy',
        :part_id => "23", :id => '42'
      }
    end
  end

  describe "handling GET /manage/parts/23/plugin/extra with AJAX" do
    before(:each) do
      @part = mock_model(Part, :class_name => 'Part', :table_name => 'parts' )
      @part.stub!(:current_plugin=).and_return(true)
      Part.stub!(:find).and_return(@part)
    end

    def do_get
      get :show, :part_id => 23, :id => 'extra', :format => 'js'
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find the requested part" do
      Part.should_receive(:find).with("23").and_return(@part)
      do_get
    end

    it "should assign the found part for the view" do
      do_get
      assigns[:part].should equal(@part)
    end

    it "should assign the plugin for the view" do
      do_get
      assigns[:plugin].should == 'extra'
    end

    it "should set the plugin for the part" do
      @part.should_receive(:current_plugin=).with("extra")
      do_get
    end

  end

  describe "handling DELETE /manage/parts/23/plugin/extra with ajax" do
    before(:each) do
      @part = mock_model(Part, :table_name => 'parts')
      @part.stub!(:current_plugin=).and_return(true)
      @part.stub!(:remove_plugin!).and_return(true)
      Part.stub!(:find).and_return(@part)
    end

    def do_delete
      get :destroy, :part_id => 23, :id => 'extra', :format => 'js'
    end

    it "should be successful" do
      do_delete
      response.should be_success
    end

    it "should find the requested part" do
      Part.should_receive(:find).with("23").and_return(@part)
      do_delete
    end

    it "should assign the found part for the view" do
      do_delete
      assigns[:part].should equal(@part)
    end

    it "should assign the plugin for the view" do
      do_delete
      assigns[:plugin].should == 'extra'
    end

    it "should delete the alternative liquid code and configuration" do
      @part.should_receive(:remove_plugin!).with("extra").and_return(true)
      do_delete
    end

    it "should not destroy the Part itself" do
      @part.should_not_receive(:destroy)
      do_delete
    end

  end

end
