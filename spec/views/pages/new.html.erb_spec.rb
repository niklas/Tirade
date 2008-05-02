require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/new.html.erb" do
  include PagesHelper
  
  before(:each) do
    @page = mock_model(Page)
    @page.stub!(:new_record?).and_return(true)
    @page.stub!(:title).and_return("MyString")
    @page.stub!(:wanted_parent_id).and_return(1)
    @page.stub!(:layout_id).and_return("1")
    @page.stub!(:yui).and_return("doc")
    assigns[:page] = @page
  end

  it "should render new form" do
    render "/pages/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", pages_path) do
      with_tag("input#page_title[name=?]", "page[title]")
      with_tag('select#page_wanted_parent_id[name=?]', "page[wanted_parent_id]")
      with_tag('select#page_layout_id[name=?]', "page[layout_id]")
      with_tag('select#page_yui[name=?]', "page[yui]")
    end
  end
end


