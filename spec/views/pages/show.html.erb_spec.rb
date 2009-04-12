require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/show.html.erb" do
  include PagesHelper
  
  before(:each) do
    @page = mock_model(
      Page,
      :title => "MyString",
      :url => "MyString",
      :parent_id => "1",
      :parent => nil,
      :layout => nil,
      :final_layout => nil,
      :yui_name => '111%',
      :root? => true,
      :children => [],
      :renderings => [],
      :markup? => false,
      :width => 'auto',
      :alignment => 'center',
      :table_name => 'pages'
    )

    assigns[:page] = @page
  end

  it "should render attributes" do
    render "/pages/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/1/)
    response.should have_text(/1/)
  end

end

