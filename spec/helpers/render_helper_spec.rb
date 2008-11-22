require File.dirname(__FILE__) + '/../spec_helper'

RenderHelper.module_eval do
  include ApplicationHelper
end

describe RenderHelper, ' a single Grid' do
  before(:each) do
    @grid = Grid.new_by_yui('yui-g')
  end
  it "should render it in a _single_ YUI div" do
    markup = helper.render_grid(@grid)
    markup.should_not be_empty
    markup.should have_tag('div.yui-u')
  end
end

describe RenderHelper, ' a 50/50 Grid with both children' do
  before(:each) do
    @grid = Grid.new_by_yui('yui-g')

    @left_grid = @grid.add_child
    @right_grid = @grid.add_child
  end
  it "should render the left sub-grid for itself" do
    markup = helper.render_grid(@left_grid)
    markup.should_not be_empty
    markup.should have_tag('div.yui-u')
  end
  it "should render the right sub-grid for itself" do
    markup = helper.render_grid(@right_grid)
    markup.should_not be_empty
    markup.should have_tag('div.yui-u')
  end
  it "should render the outer Grid with both children in it" do
    markup = helper.render_grid(@grid)
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
      markup = helper.render_grid(@grid)
      markup.should_not be_empty
      markup.should have_tag('div.yui-gc') do
        with_tag('div.yui-u.first')
        with_tag('div.yui-u.first + div.yui-u')
      end
    end
  end
end

describe RenderHelper, ", rendering the main page" do
  fixtures :all
  before(:each) do
    @page = pages(:main)
  end

  it "should not be blank" do
    pending("Helprt should be able to use render")
    @html = render_page(@page)
    @html.should_not be_blank
  end

end
