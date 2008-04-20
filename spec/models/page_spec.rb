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
    @page = pages(:main)
    Page.rebuild!
    Grid.rebuild!
    Content.rebuild!
  end
  it "should have the right final_layout" do
    @page.final_layout.id.should == grids(:layout50_50).id
  end
  it "should have some renderings" do
    @page.should have_at_least(3).renderings
  end
  it "should have some contents" do
    @page.should have_at_least(2).contents
  end

  it "should have some parts" do
    @page.should have_at_least(2).parts
  end
end
