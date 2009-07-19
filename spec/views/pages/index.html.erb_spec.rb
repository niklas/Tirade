require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pages/index.html.erb" do
  ActionView::Base.class_eval do
    include PagesHelper
    include InterfaceHelper
  end
  
  before(:each) do
    main_page = Factory(:page, :title => 'Main', :url => 'main')
    sub_page  = Factory(:page, :title => 'sub', :url => 'main/sub')

    assigns[:pages] = [main_page, sub_page]
    assigns[:collection] = [main_page, sub_page]
    template.stub!(:human_name).and_return('Page')
  end

  it "should use a template" do
    template.should_not be_nil
  end

  it "should use a template with a controller" do
    template.controller.should_not be_nil
  end

  it "should render list of pages" do
    render "index.html.erb"
    response.should be_success
    response.body.should_not be_empty
  end
end

