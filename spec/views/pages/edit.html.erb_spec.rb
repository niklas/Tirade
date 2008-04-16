require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/edit.html.erb" do
  include PagesHelper
  
  before do
    @page = mock_model(Page)
    @page.stub!(:title).and_return("MyString")
    @page.stub!(:url).and_return("MyString")
    @page.stub!(:parent_id).and_return("1")
    @page.stub!(:lft).and_return("1")
    @page.stub!(:rgt).and_return("1")
    @page.stub!(:layout_id).and_return("1")
    assigns[:page] = @page
  end

  it "should render edit form" do
    render "/pages/edit.html.erb"
    
    response.should have_tag("form[action=#{page_path(@page)}][method=post]") do
      with_tag('input#page_title[name=?]', "page[title]")
      with_tag('input#page_url[name=?]', "page[url]")
      with_tag('input#page_lft[name=?]', "page[lft]")
      with_tag('input#page_rgt[name=?]', "page[rgt]")
    end
  end
end


