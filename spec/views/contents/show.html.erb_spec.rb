require File.dirname(__FILE__) + '/../../spec_helper'

describe "/contents/show.html.erb" do
  include ContentsHelper
  
  before(:each) do
    @content = mock_model(Content)
    @content.stub!(:title).and_return("MyString")
    @content.stub!(:description).and_return("MyText")
    @content.stub!(:body).and_return("MyText")
    @content.stub!(:type).and_return("MyString")
    @content.stub!(:state).and_return("MyString")
    @content.stub!(:owner_id).and_return("1")
    @content.stub!(:published_at).and_return(Time.now)
    @content.stub!(:parent_id).and_return("1")
    @content.stub!(:images).and_return([])

    assigns[:content] = @content
  end

  it "should render attributes in <p>" do
    render "/contents/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyText/)
    response.should have_text(/MyText/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
  end
end

