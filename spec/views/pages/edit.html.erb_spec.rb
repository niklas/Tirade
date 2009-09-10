require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/edit.html.erb" do
  ActionView::Base.class_eval do
    include PagesHelper
    include InterfaceHelper
  end
  
  before do
    @page = Factory(:page)
    template.stub!(:model_name).and_return('Page')
    template.stub!(:model).and_return(Page)
    assigns[:page] = @page
    assigns[:object] = @page
  end

  it "should render edit form with some fields" do
    render "edit.html.erb"
    
    response.should have_tag("form[action=#{page_path(@page)}][method=post]") do
    #    with_tag('label', 'Title')
       with_tag('input#page_title[name=?]', "page[title]")
    #    with_tag('label', 'Parent Page')
       with_tag('select#page_parent_id[name=?]', "page[parent_id]")
    #    with_tag('label', 'Layout')
       with_tag('select#page_layout_id[name=?]', "page[layout_id]")
    #    with_tag('label', 'Width')
       with_tag('select#page_alignment[name=?]', "page[alignment]")
       with_tag('input#page_width')
    end
  end
end


