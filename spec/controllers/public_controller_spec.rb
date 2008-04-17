require File.dirname(__FILE__) + '/../spec_helper'

describe PublicController do
  fixtures :all
  before(:each) do
    Page.rebuild!
  end

  #Delete these examples and add some real ones
  it "should use PublicController" do
    controller.should be_an_instance_of(PublicController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe 'route recognition' do
    it "should recognize ''" do
      params_from(:get, '').should == {:controller => 'public', :action => 'index'}
    end
    it "should recognize '/'" do
      params_from(:get, '/').should == {:controller => 'public', :action => 'index'}
    end
    it "should recognize '/foo/bar'" do
      params_from(:get, '/foo/bar').should == {:controller => 'public', :action => 'index', :path => ['foo','bar']}
    end
    it "should recognize '/portal/children-section'" do
      params_from(:get, '/portal/children-section').should == {:controller => 'public', :action => 'index', :path => ['portal','children-section']}
    end
  end

  describe 'url recognition' do
    it "should accept ''" do
      Page.should_receive(:root).and_return( pages(:main) )
      get :index
      assigns[:url].should == ''
      assigns[:page].should_not be_nil
    end
    it "should accept '/foo/bar'" do
      Page.should_receive(:find_by_url).with('foo/bar').and_return( nil )
      get :index, :path => ['foo','bar']
      assigns[:url].should == 'foo/bar'
      assigns[:page].should be_nil
    end
    it "should accept '/foo/bar' with extra param" do
      Page.should_receive(:find_by_url).with('foo/bar').and_return( nil )
      get :index, :path => ['foo','bar'], :q => 'some param'
      assigns[:url].should == 'foo/bar'
      assigns[:page].should be_nil
    end
    it "should accept '/foo/bar' with extra params" do
      Page.should_receive(:find_by_url).with('foo/bar').and_return( nil )
      get :index, :path => ['foo','bar'], :q => 'some param', :x => 'you know', :y => 'do we need this?'
      assigns[:url].should == 'foo/bar'
      assigns[:page].should be_nil
    end
    it "should accept '/portal/children-section'" do
      Page.should_receive(:find_by_url).with('portal/children-section').and_return( pages(:children_section) )
      get :index, :path => ['portal','children-section']
      assigns[:url].should == 'portal/children-section'
      assigns[:page].should == pages(:children_section)
    end
  end
end
