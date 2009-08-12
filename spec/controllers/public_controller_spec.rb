require File.dirname(__FILE__) + '/../spec_helper'

describe PublicController do
  fixtures :all
  #Delete these examples and add some real ones
  it "should use PublicController" do
    controller.should be_an_instance_of(PublicController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "should show a link to log in" do
      get 'index'
      response.should have_tag('.loginout') do
        with_tag 'a.login'
      end
    end
  end

  describe 'route recognition' do
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
      assigns[:page].should_not be_nil
    end
    it "should accept '/foo/bar'" do
      Page.should_receive(:find_by_url).with('foo/bar').and_return( nil )
      Page.should_receive(:find_by_url).with('foo').and_return( nil )
      get :index, :path => ['foo','bar']
      assigns[:page].should be_nil
    end
    it "should accept '/foo/bar' with extra param" do
      Page.should_receive(:find_by_url).with('foo/bar').and_return( nil )
      Page.should_receive(:find_by_url).with('foo').and_return( nil )
      get :index, :path => ['foo','bar'], :q => 'some param'
      assigns[:page].should be_nil
    end
    it "should accept '/foo/bar' with extra params" do
      Page.should_receive(:find_by_url).with('foo/bar').and_return( nil )
      Page.should_receive(:find_by_url).with('foo').and_return( nil )
      get :index, :path => ['foo','bar'], :q => 'some param', :x => 'you know', :y => 'do we need this?'
      assigns[:page].should be_nil
    end
    it "should accept '/portal/children-section'" do
      Page.should_receive(:find_by_url).with('portal/children-section').and_return( pages(:children_section) )
      get :index, :path => ['portal','children-section']
      assigns[:page_path].should == %w(portal children-section)
      assigns[:trailing_path].should be_empty
      assigns[:page].should == pages(:children_section)
    end
  end

  describe 'content - heavy urls' do # könnte man auch halbdynamisch (einmal beim start?) in /config/routes.rb generieren...
    it "should try to find ancestor pages" do
      Page.should_receive(:find_by_url).with('part1/part2/part3/part4/part5').and_return( nil )
      Page.should_receive(:find_by_url).with('part1/part2/part3/part4').and_return( nil )
      Page.should_receive(:find_by_url).with('part1/part2/part3').and_return( nil )
      Page.should_receive(:find_by_url).with('part1/part2').and_return( nil )
      Page.should_receive(:find_by_url).with('part1').and_return( nil )
      get :index, :path => %w(part1 part2 part3 part4 part5)
      assigns[:page].should be_nil
      assigns[:page_path].should be_empty
      assigns[:trailing_path].should == %w(part1 part2 part3 part4 part5)
    end

    it "should find the children-section if asking for it's nonexisting subpages" do
      Page.should_receive(:find_by_url).with('portal/children-section/fluffy-animals/sexual-harassment-panda').and_return(nil)
      Page.should_receive(:find_by_url).with('portal/children-section/fluffy-animals').and_return( pages(:fluffy_animals) )
      get :index, :path => %w(portal children-section fluffy-animals sexual-harassment-panda)
      assigns[:page].should_not be_nil
      assigns[:page_path].should == %w(portal children-section fluffy-animals)
      assigns[:trailing_path].should == %w(sexual-harassment-panda)
    end

    it "should find the children section, its content for the subpages and ringtone for one of them" do
      pending("Sub-Content selection happens in Parts")
      Page.should_receive(:find_by_url).with('portal/children-section/fluffy-animals/sexual-harassment-panda').and_return(nil)
      Page.should_receive(:find_by_url).with('portal/children-section/fluffy-animals').and_return( a_page_with_attached_content_type)
      panda = a_fluffy_panda
      panda.should_receive(:ringtone).and_return( annoying_panda_ringtone )
      Content.should_recieve(:find_by_url).with('sexual-harassment-panda').and_return( panda )
      get :index, :path => %w(portal children-section fluffy-animals sexual-harassment-panda ringtone)
    end
  end


end

describe PublicController, "accessing not existing page" do
  integrate_views
  describe "not logged in" do
    it "should be successful" do
      get :index, :path => %w(posts 1)
      response.should be_success
    end
    it "should be 'Not Found'"
  end
end
