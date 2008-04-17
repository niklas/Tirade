require File.dirname(__FILE__) + '/../../spec_helper'

describe "/contents/index.html.erb" do
  include ContentsHelper
  
  before(:each) do
    content_98 = mock_model(Content)
    content_98.should_receive(:title).and_return("MyString")
    content_98.should_receive(:description).and_return("MyText")
    content_98.should_receive(:body).and_return("MyText")
    content_98.should_receive(:type).and_return("MyString")
    content_98.should_receive(:state).and_return("MyString")
    content_98.should_receive(:owner_id).and_return("1")
    content_98.should_receive(:published_at).and_return(Time.now)
    content_98.should_receive(:position).and_return("1")
    content_98.should_receive(:parent_id).and_return("1")
    content_98.should_receive(:lft).and_return("1")
    content_98.should_receive(:rgt).and_return("1")
    content_99 = mock_model(Content)
    content_99.should_receive(:title).and_return("MyString")
    content_99.should_receive(:description).and_return("MyText")
    content_99.should_receive(:body).and_return("MyText")
    content_99.should_receive(:type).and_return("MyString")
    content_99.should_receive(:state).and_return("MyString")
    content_99.should_receive(:owner_id).and_return("1")
    content_99.should_receive(:published_at).and_return(Time.now)
    content_99.should_receive(:position).and_return("1")
    content_99.should_receive(:parent_id).and_return("1")
    content_99.should_receive(:lft).and_return("1")
    content_99.should_receive(:rgt).and_return("1")

    assigns[:contents] = [content_98, content_99]
  end

  it "should render list of contents" do
    render "/contents/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyText", 2)
    response.should have_tag("tr>td", "MyText", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "1", 2)
    response.should have_tag("tr>td", "1", 2)
    response.should have_tag("tr>td", "1", 2)
  end
end

