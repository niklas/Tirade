require File.dirname(__FILE__) + '/../../spec_helper'

describe "/renderings/index.html.erb" do
  include RenderingsHelper
  
  before(:each) do
    rendering_98 = mock_model(Rendering)
    rendering_98.should_receive(:page_id).and_return("1")
    rendering_98.should_receive(:content_id).and_return("1")
    rendering_98.should_receive(:part_id).and_return("1")
    rendering_98.should_receive(:grid_id).and_return("1")
    rendering_98.should_receive(:position).and_return("1")
    rendering_99 = mock_model(Rendering)
    rendering_99.should_receive(:page_id).and_return("1")
    rendering_99.should_receive(:content_id).and_return("1")
    rendering_99.should_receive(:part_id).and_return("1")
    rendering_99.should_receive(:grid_id).and_return("1")
    rendering_99.should_receive(:position).and_return("1")

    assigns[:renderings] = [rendering_98, rendering_99]
  end

  it "should render list of renderings" do
    render "/renderings/index.html.erb"
    response.should have_tag("tr>td", "1", 2)
  end
end

