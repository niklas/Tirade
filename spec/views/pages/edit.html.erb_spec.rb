require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/edit.html.erb" do
  include PagesHelper
  
  before do
    @page = mock_model Page,
      :title => 'Main',
      :url => 'main',
      :wanted_parent_id => 1,
      :table_name => 'pages',
      :class_name => 'Page',
      :root? => false,
      :layout_id => 23,
      :yui => 'doc'

    assigns[:page] = @page
    template.controller.stub!(:controller_name).and_return("pages")
  end

  it "should render edit form" do
    render "edit.html.erb"
    
    response.should have_tag("form[action=#{page_path(@page)}][method=post]") do
      with_tag('div.title') do
        with_tag('label', 'Title')
        with_tag('input#page_title[name=?]', "page[title]")
      end
      with_tag('div.parent_page') do
        with_tag('label', 'Parent Page')
        with_tag('select#page_wanted_parent_id[name=?]', "page[wanted_parent_id]")
      end
      with_tag('div.layout') do
        with_tag('label', 'Layout')
        with_tag('select#page_layout_id[name=?]', "page[layout_id]")
      end
      with_tag('div.width') do
        with_tag('label', 'Width')
        with_tag('select#page_yui[name=?]', "page[yui]")
      end
    end
  end
end


