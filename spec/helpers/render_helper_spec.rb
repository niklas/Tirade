require File.dirname(__FILE__) + '/../spec_helper'

describe RenderHelper, 'rendering' do
  before( :each ) do
    helper.stub!(:render).and_return("like all #render call results")
  end
  describe "page" do
    fixtures :pages
    it "should render partial" do
      helper.should_receive(:render).with(
        :partial => 'pages/page',
        :object => pages(:main),
        :locals => {}
      ).and_return('page partial')
      helper.render_page( pages(:main) ).should == 'page partial'
    end
  end
  describe "grid" do
    fixtures :grids
    it "should render partial" do
      helper.should_receive(:render).with(
        :partial => 'grids/grid',
        :object => grids(:main_vs_sidebar),
        :layout => 'grids/wrapper',
        :locals => {:page => false}
      ).and_return('grid partial')
      helper.render_grid( grids(:main_vs_sidebar) ).should == 'grid partial'
    end
  end
  describe "rendering" do
    fixtures :renderings
    it "should render partial" do
      helper.should_receive(:render).with(
        :partial => 'renderings/rendering',
        :object => renderings(:ddm_welcome),
        :locals => {:page => false, :grid => false}
      ).and_return('rendering partial')
      helper.render_rendering( renderings(:ddm_welcome) ).should == 'rendering partial'
    end
  end
  
end
