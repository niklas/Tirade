require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Part::ThemeController do
  before :each do
    login_as :valid_user
  end
  describe "route generation" do
    it "should map { :action => 'show', :id => 'test', :part_id => 23} to /manage/parts/23/theme/test" do
      route_for(:controller => 'part/theme', :action => 'show', :id => 'test', :part_id => '23').should == 
        "/manage/parts/23/theme/test"
    end
  end

  describe "route recognition" do
    it "should generate params { :action => 'show', :id => 'test', :part_id => 23} from GET /manage/parts/23/theme/test" do
      params_from(:get, '/manage/parts/23/theme/test').should == {
        :controller => 'part/theme', :action => 'show',
        :part_id => "23", :id => 'test'
      }
    end
  end

  describe "handling GET /manage/parts/23/theme/test with AJAX" do
    before(:each) do
      @part = mock_model(Part, :class_name => 'Part', :table_name => 'parts' )
      @part.stub!(:current_theme=).and_return(true)
      Part.stub!(:find).and_return(@part)
    end

    def do_get
      get :show, :part_id => 23, :id => 'test', :format => 'js'
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

    it "should assign the theme for the view" do
      do_get
      assigns[:theme].should == 'test'
    end

    it "should set the theme for the part" do
      @part.should_receive(:current_theme=).with("test")
      do_get
    end

  end

  describe "handling DELETE /manage/parts/23/theme/test with ajax" do
    before(:each) do
      @part = mock_model(Part, :table_name => 'parts')
      @part.stub!(:current_theme=).and_return(true)
      @part.stub!(:remove_theme!).and_return(true)
      Part.stub!(:find).and_return(@part)
    end

    def do_delete
      get :destroy, :part_id => 23, :id => 'test', :format => 'js'
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

    it "should assign the theme for the view" do
      do_delete
      assigns[:theme].should == 'test'
    end

    it "should delete the alternative liquid code and configuration" do
      @part.should_receive(:remove_theme!).with("test").and_return(true)
      do_delete
    end

    it "should not destroy the Part itself" do
      @part.should_not_receive(:destroy)
      do_delete
    end

  end

end
