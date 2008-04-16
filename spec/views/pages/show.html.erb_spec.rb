require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/show.html.erb" do
  include PagesHelper
  
  before(:each) do
    @page = mock_model(Page)
    @page.stub!(:title).and_return("MyString")
    @page.stub!(:url).and_return("MyString")
    @page.stub!(:parent_id).and_return("1")
    @page.stub!(:lft).and_return("1")
    @page.stub!(:rgt).and_return("1")
    @page.stub!(:layout_id).and_return("1")

    assigns[:page] = @page
  end

  it "should render attributes in <p>" do
    render "/pages/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/1/)
    response.should have_text(/1/)
  end
end

