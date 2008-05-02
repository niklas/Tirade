require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/edit.html.erb" do
  include PagesHelper
  
  before do
    @page = mock_model(Page)
    @page.stub!(:title).and_return("MyString")
    @page.stub!(:wanted_parent_id).and_return(1)
    @page.stub!(:layout_id).and_return("1")
    @page.stub!(:yui).and_return("doc")
    assigns[:page] = @page
  end

  it "should render edit form" do
    render "/pages/edit.html.erb"
    
    response.should have_tag("form[action=#{page_path(@page)}][method=post]") do
      with_tag('input#page_title[name=?]', "page[title]")
      with_tag('select#page_wanted_parent_id[name=?]', "page[wanted_parent_id]")
      with_tag('select#page_layout_id[name=?]', "page[layout_id]")
      with_tag('select#page_yui[name=?]', "page[yui]")
    end
  end
end


