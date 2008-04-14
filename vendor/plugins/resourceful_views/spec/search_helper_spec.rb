require File.dirname(__FILE__) + '/spec_helper'


describe 'search_resource with plural resource' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days
    end
    @view = ActionView::Base.new
    @view.stub!(:days_path).and_return('/days')
  end
  
  it "should render a form GETTing to the resource path" do
    markup = @view.search_days
    markup.should have_tag('form[action=/days][method=get]')
  end
  
  it "should render a search_resource form" do
    markup = @view.search_days
    markup.should have_tag('form.search.days.search_days')
  end
  
  it "should render a 'Search' submit button by default" do
    markup = @view.search_days
    markup.should have_tag('button[type=submit]', 'Search')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.search_days(:label => 'Find')
    markup.should have_tag('button[type=submit]', 'Find')
  end
  
  it "should render a text field for the query" do
    markup = @view.search_days
    markup.should have_tag('input[type=text][name=query]')
  end
  
  it "should fill in the instance variable @query as the query value" do
    pending('Trouble getting assigns to work here')
    @view.stub!(:assigns).and_return({:query => 'sunny'})
    markup = @view.search_days
    markup.should have_tag('input[type=text][name=query][value=sunny]')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option"
  
end


describe 'search_resource with plural nested resource' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days do |day|
        day.resources :hours
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:day_hours_path).and_return('/days/1/hours')
    @day = mock('day')
  end
  
  it "should render a form GETTing to the resource path" do
    markup = @view.search_day_hours(@day)
    markup.should have_tag('form[action=/days/1/hours][method=get]')
  end
  
  it "should render a search_resource form" do
    markup = @view.search_day_hours(@day)
    markup.should have_tag('form.search.hours.search_hours')
  end
  
  it "should render a 'Search' submit button by default" do
    markup = @view.search_day_hours(@day)
    markup.should have_tag('button[type=submit]', 'Search')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.search_day_hours(@day, :label => 'Find')
    markup.should have_tag('button[type=submit]', 'Find')
  end
  
  it "should render a text field for the query" do
    markup = @view.search_day_hours(@day)
    markup.should have_tag('input[type=text][name=query]')
  end
  
  it "should fill in the instance variable @query as the query value" do
    pending('Trouble getting assigns to work here')
    @view.stub!(:assigns).and_return({:query => 'sunny'})
    markup = @view.search_day_hours(@day)
    markup.should have_tag('input[type=text][name=query][value=sunny]')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option"
  
end

