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
      :final_layout => nil,
      :yui_name => '111%',
      :root? => true,
      :children => [],
      :renderings => [],
      :markup? => false
    )

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

