require File.dirname(__FILE__) + '/../../spec_helper'

describe "/renderings/show.html.erb" do
  include RenderingsHelper
  
  before(:each) do
    @rendering = mock_model(Rendering)
    @rendering.stub!(:page_id).and_return("1")
    @rendering.stub!(:content_id).and_return("1")
    @rendering.stub!(:part_id).and_return("1")
    @rendering.stub!(:grid_id).and_return("1")
    @rendering.stub!(:position).and_return("1")

    assigns[:rendering] = @rendering
  end

  it "should render attributes in <p>" do
    render "/renderings/show.html.erb"
    response.should have_text(/1/)
  end
end

