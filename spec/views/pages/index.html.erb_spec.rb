require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/index.html.erb" do
  include PagesHelper
  fixtures(:all)
  
  before(:each) do
    page_98 = mock_model(Page)
    page_98.should_receive(:title).and_return("Title1")
    page_98.should_receive(:url).and_return("url1")
    page_98.should_receive(:final_layout).and_return(grids(:layout50_50))
    page_98.should_receive(:updated_at).and_return(Time.now.yesterday)
    page_99 = mock_model(Page)
    page_99.should_receive(:title).and_return("Title2")
    page_99.should_receive(:url).and_return("url2")
    page_99.should_receive(:final_layout).and_return(grids(:layout50_50))
    page_99.should_receive(:updated_at).and_return(Time.now.yesterday.yesterday)

    assigns[:pages] = [page_98, page_99]
  end

  it "should render list of pages" do
    render "/pages/index.html.erb"
    response.should have_tag("tr>td", "Title1", 2)
    response.should have_tag("tr>td", "Title2", 2)
    response.should have_tag("tr>td", "url1", 2)
    response.should have_tag("tr>td", "url2", 2)
  end
end

