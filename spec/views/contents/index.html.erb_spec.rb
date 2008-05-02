require File.dirname(__FILE__) + '/../../spec_helper'

describe "/contents/index.html.erb" do
  include ContentsHelper
  
  before(:each) do
    content_98 = mock_model(Content)
    content_98.should_receive(:title).and_return("Title 98")
    content_98.should_receive(:description).and_return("Description 98")
    content_98.should_receive(:body).and_return("Body 98")
    content_98.should_receive(:updated_at).and_return(Time.now - 10.seconds)
    
    content_99 = mock_model(Content)
    content_99.should_receive(:title).and_return("Title 99")
    content_99.should_receive(:description).and_return("Description 99")
    content_99.should_receive(:body).and_return("Body 99")
    content_99.should_receive(:updated_at).and_return(Time.now.yesterday)
    assigns[:contents] = [content_98, content_99]
  end

  it "should render list of contents" do
    render "/contents/index.html.erb"
    response.should have_tag("tr>td>a", "Title 98", 1)
    response.should have_tag("tr>td", "Description 98", 1)
    response.should have_tag("tr>td", "Body 98", 1)
    response.should have_tag("tr>td", /less than a minute ago/)
    response.should have_tag("tr>td>a", "show", 2)
    response.should have_tag("tr>td>a", "edit", 2)
    response.should have_tag("tr>td>a", "Destroy", 2)

    response.should have_tag("tr>td>a", "Title 99", 1)
    response.should have_tag("tr>td", "Description 99", 1)
    response.should have_tag("tr>td", "Body 99", 1)
    response.should have_tag("tr>td", /1 day ago/)
  end
end

