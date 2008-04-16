require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  before(:each) do
    @page = Page.new
  end

  it "should not be valid" do
    @page.should_not be_valid
  end
end

describe "A Page with a title" do
  before(:each) do
    @page = Page.new(
      :title => "A Simple Page"
    )
  end
  it "should be valid" do
    @page.should be_valid
  end

  it "should be able to call its parent" do
    @page.should respond_to(:parent)
  end
end



describe "The Pages in the fixtures" do
  fixtures :pages, :grids

  before(:each) do
    @pages = Page.find(:all)
  end

  it "should be there" do
    @pages.should_not be_empty
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

end
