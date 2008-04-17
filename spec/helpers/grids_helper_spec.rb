require File.dirname(__FILE__) + '/../spec_helper'

describe GridsHelper do
  
  it "should include the GridsHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(GridsHelper)
  end

end

describe GridsHelper, ' a single Grid' do
  before(:each) do
    @grid = Grid.new_by_yui('yui-g')
  end
  it "should render it in a _single_ YUI div" do
    markup = render_grid(@grid)
    markup.should_not be_empty
    markup.should have_tag('div.yui-u')
  end
end

describe GridsHelper, ' a 50/50 Grid with both children' do
  before(:each) do
    @grid = Grid.new_by_yui('yui-g')

    @left_grid = @grid.add_child
    @right_grid = @grid.add_child
  end
  it "should render the left sub-grid for itself" do
    markup = render_grid(@left_grid)
    markup.should_not be_empty
    markup.should have_tag('div.yui-u')
  end
  it "should render the right sub-grid for itself" do
    markup = render_grid(@right_grid)
    markup.should_not be_empty
    markup.should have_tag('div.yui-u')
  end
  it "should render the outer Grid with both children in it" do
    markup = render_grid(@grid)
    markup.should_not be_empty
    markup.should have_tag('div.yui-g') do
      with_tag('div.yui-u.first')
      with_tag('div.yui-u.first + div.yui-u')
    end
  end

  describe 'and if we change it to a 1/3 - 2/3' do
    before(:each) do
      @grid.yui = 'yui-gc'
    end
    it "should render it accordingly" do
      markup = render_grid(@grid)
      markup.should_not be_empty
      markup.should have_tag('div.yui-gc') do
        with_tag('div.yui-u.first')
        with_tag('div.yui-u.first + div.yui-u')
      end
    end
  end
end
