require File.dirname(__FILE__) + '/../spec_helper'

describe GridHelper do
  
  it "should include the GridHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(GridHelper)
  end

end

describe GridHelper, ' a single Grid' do
  before(:each) do
    @grid = mock_model(Grid, :grid_class => 'yui-g')
  end
  it "should render it in a YUI div" do
    markup = render_grid(@grid)
    markup.should_not be_empty
    markup.should have_tag('div.yui-g')
  end
end
