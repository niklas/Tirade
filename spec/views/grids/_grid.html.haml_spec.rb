require File.dirname(__FILE__) + '/../../spec_helper'

describe "/grids/_grid.html.haml" do
  include RenderHelper
  before( :each ) do
    template.view_paths.unshift 'app/views'
  end

  it "should succeed" do
    pending("searches grid partial layout in wrong dir")
    render_grid Factory(:grid)
    response.should be_success
  end

end
