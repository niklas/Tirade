require File.dirname(__FILE__) + '/../spec_helper'

RenderHelper.module_eval do
  include ApplicationHelper
end

describe RenderHelper, ' a single Grid' do
  before(:each) do
    @grid = Grid.new(:division => 'leaf')
  end
  it "should render it in a _single_ YUI div" do
    markup = helper.render_grid(@grid)
    markup.should_not be_empty
    markup.should have_tag('div')
  end
end

describe RenderHelper, 'renders a 50/50 Grid with both children' do
  before(:each) do
    @grid = Grid.create!(:division => '50-50')

    @left_grid = @grid.children[0]
    @right_grid = @grid.children[1]
  end
  it "should render the left sub-grid for itself" do
    markup = helper.render_grid(@left_grid)
    markup.should_not be_empty
    markup.should have_tag('div.subcl')
  end
  it "should render the right sub-grid for itself" do
    markup = helper.render_grid(@right_grid)
    markup.should_not be_empty
    markup.should have_tag('div.subcr')
  end
  it "should render the outer Grid with both children in it" do
    markup = helper.render_grid(@grid)
    markup.should_not be_empty
    markup.should have_tag('div.subcolumns') do
      with_tag('div.c50l div.subcl')
      with_tag('div.c50r div.subcr')
    end
  end

  describe 'and if we change it to a 1/3 - 2/3' do
    before(:each) do
      @grid.division = '33-66'
    end
    it "should render it accordingly" do
      markup = helper.render_grid(@grid)
      markup.should_not be_empty
      markup.should have_tag('div.subcolumns') do
        with_tag('div.c33l div.subcl')
        with_tag('div.c66r div.subcr')
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
