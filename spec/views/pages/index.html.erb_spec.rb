require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/index.html.erb" do
  include PagesHelper
  fixtures(:all)
  
  before(:each) do
    main_page = mock_model Page,
      :title => 'Main',
      :url => 'main',
      :table_name => 'pages'
    sub_page = mock_model Page,
      :title => 'Sub',
      :url => 'main/sub',
      :table_name => 'pages'

    assigns[:pages] = [main_page, sub_page]
  end

  it "should use a template" do
    template.should_not be_nil
  end

  it "should use a template with a controller" do
    template.controller.should_not be_nil
  end

  it "should render list of pages" do
    template.controller.should_receive(:controller_name).twice.and_return("pages")
    render "index.html.erb"
    response.should be_success
    response.body.should_not be_empty
  end
end

