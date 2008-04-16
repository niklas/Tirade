require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/index.html.erb" do
  include PagesHelper
  
  before(:each) do
    page_98 = mock_model(Page)
    page_98.should_receive(:title).and_return("MyString")
    page_98.should_receive(:url).and_return("MyString")
    page_98.should_receive(:parent_id).and_return("1")
    page_98.should_receive(:lft).and_return("1")
    page_98.should_receive(:rgt).and_return("1")
    page_98.should_receive(:layout_id).and_return("1")
    page_99 = mock_model(Page)
    page_99.should_receive(:title).and_return("MyString")
    page_99.should_receive(:url).and_return("MyString")
    page_99.should_receive(:parent_id).and_return("1")
    page_99.should_receive(:lft).and_return("1")
    page_99.should_receive(:rgt).and_return("1")
    page_99.should_receive(:layout_id).and_return("1")

    assigns[:pages] = [page_98, page_99]
  end

  it "should render list of pages" do
    render "/pages/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "1", 2)
    response.should have_tag("tr>td", "1", 2)
  end
end

