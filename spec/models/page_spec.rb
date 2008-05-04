require File.dirname(__FILE__) + '/../spec_helper'

describe "A Page with a title" do
  before(:each) do
    @page = Page.new(
      :title => "A Simple Page"
    )
  end

  it "should be able to call its parent" do
    @page.should respond_to(:parent)
  end
end



describe "The Pages in the fixtures" do
  fixtures :pages, :grids

  before(:each) do
    Page.rebuild!
    @pages = Page.find(:all)
  end

  it "should be there" do
    @pages.should_not be_empty
  end

  it "should be valid" do
    @pages.each do |page|
      page.should be_valid
    end
  end

  it "should have an url" do
    @pages.each do |page|
      page.url.should_not be_nil
    end
  end

  it "should be findable by its url" do
    @pages.each do |page|
      Page.find_by_url(page.url).id.should == page.id
    end
  end

  it "should generate the correct url" do
    @pages.each do |page|
      page.generated_url.should == page.url
    end
  end

  it "should have a final_layout" do
    @pages.each do |page|
      page.final_layout.should_not be_nil
    end
  end

  describe ", the page about Huge Brutal Hammers" do
    before(:each) do
      @page = pages(:hammers)
    end
    it "should have a special layout" do
      @page.layout.id.should == grids(:layout33_33_33).id
    end
    it "should have its own final layout" do
      @page.final_layout.id.should == @page.layout.id
    end
    it "should know all its ancestors" do
      ancestors = @page.ancestors
      ancestors.should include( pages(:main) )
      ancestors.should include( pages(:portal) )
      ancestors.should include( pages(:children_section) )
    end
  end
end


describe "The main Page with all fixtures" do
  fixtures :all
  before(:each) do
    Page.rebuild!
    Grid.rebuild!
    Content.rebuild!
    @page = pages(:main)
  end
  it "should have the right final_layout" do
    @page.final_layout.id.should == grids(:layout50_50).id
  end
  it "should have some renderings" do
    @page.should have_at_least(3).renderings
  end
  # FIXME does not work wiht polymorphic (see page.rb)
  #it "should have some contents" do
  #  @page.should have_at_least(2).contents
  #end
  it "should have some contents"
  it "should have some parts" do
    @page.should have_at_least(2).parts
  end
  it "should have some grids" do
    @page.should have_at_least(3).grids
  end

  describe ", rendering it" do
    before(:each) do
      @page.active_controller = MockController.new
      @html = @page.render
    end
    it "should not be empty" do
      @html.should_not be_empty
    end
    it "should have the complete page structure" do
      @html.should have_tag('div#doc') do
        with_tag('div.grid.yui-g') do
          with_tag('div.first.grid.yui-u') do
            with_tag('div.rendering.simple_preview.document') do
              with_tag('h2', 'Welcome')
              with_tag('p', /big hug/)
            end
          end
          with_tag('div.first.grid + div.grid.yui-u') do
            with_tag('div.rendering.simple_preview.document') do
              with_tag('h2','Introduction')
              with_tag('p',/Tirade is a CMS/)
            end
          end
        end
      end
    end
    it "should have a header" do
      @html.should have_tag('div#doc') do
        with_tag('div#header')
      end
    end
    it "should habe a footer" do
      @html.should have_tag('div#doc') do
        with_tag('div#footer')
      end
    end
  end
end

describe "Having all fixtures loaded" do
  fixtures :all
  it "destroying the about page should succeed" do
    # this checks for the AR#update_all monkepatch
    lambda do
      pages(:about).destroy
    end.should_not raise_error
  end
end
