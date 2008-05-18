require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/show.html.erb" do
  include PagesHelper
  
  before(:each) do
    @page = mock_model(Page)
    @page.stub!(:title).and_return("MyString")
    @page.stub!(:url).and_return("MyString")
    @page.stub!(:parent_id).and_return("1")
    @page.stub!(:parent).and_return(nil)
    @page.stub!(:final_layout).and_return(nil)
    @page.stub!(:yui_name).and_return('111%')
    @page.stub!(:root?).and_return(true)
    @page.stub!(:children).and_return([])
    @page.stub!(:renderings).and_return([])

    assigns[:page] = @page
  end

  it "should render attributes in <p>" do
    render "/pages/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/1/)
    response.should have_text(/1/)
  end

  it "should render a page hierarchy with itself highlighted"
end

