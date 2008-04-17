require File.dirname(__FILE__) + '/../../spec_helper'

describe "/renderings/new.html.erb" do
  include RenderingsHelper
  
  before(:each) do
    @rendering = mock_model(Rendering)
    @rendering.stub!(:new_record?).and_return(true)
    @rendering.stub!(:page_id).and_return("1")
    @rendering.stub!(:content_id).and_return("1")
    @rendering.stub!(:part_id).and_return("1")
    @rendering.stub!(:grid_id).and_return("1")
    @rendering.stub!(:position).and_return("1")
    assigns[:rendering] = @rendering
  end

  it "should render new form" do
    render "/renderings/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", renderings_path) do
      with_tag("input#rendering_position[name=?]", "rendering[position]")
    end
  end
end


