require File.dirname(__FILE__) + '/../../spec_helper'

describe "/renderings/edit.html.erb" do
  include RenderingsHelper
  
  before do
    @rendering = mock_model(Rendering)
    @rendering.stub!(:page_id).and_return("1")
    @rendering.stub!(:content_id).and_return("1")
    @rendering.stub!(:part_id).and_return("1")
    @rendering.stub!(:grid_id).and_return("1")
    @rendering.stub!(:position).and_return("1")
    assigns[:rendering] = @rendering
  end

  it "should render edit form" do
    render "/renderings/edit.html.erb"
    
    response.should have_tag("form[action=#{rendering_path(@rendering)}][method=post]") do
      with_tag('input#rendering_position[name=?]', "rendering[position]")
    end
  end
end


