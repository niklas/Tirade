require File.dirname(__FILE__) + '/../../spec_helper'

describe "/renderings/index.html.erb" do
  include RenderingsHelper
  
  it "should render a toolbox" do
    render "/renderings/index.html.erb"
    response.should have_tag("div#toolbox")
  end
end

