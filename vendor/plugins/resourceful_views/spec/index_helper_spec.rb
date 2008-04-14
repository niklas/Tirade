require File.dirname(__FILE__) + '/spec_helper'


describe 'index_resource with plural resource' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days
    end
    @view = ActionView::Base.new
    @view.stub!(:days_path).and_return('/days')
  end

  it "should create a link with resourceful classes" do
    markup = @view.index_days
    markup.should have_tag('a.index.days.index_days')
  end
  
  it "should allow adding custom classes" do
    markup = @view.index_days(:class => 'search')
    markup.should have_tag('a.index.days.search.index_days.search_days')
  end
  
  it "should link to the resources_path" do
    @view.should_receive(:days_path).and_return('/days')
    markup = @view.index_days
    markup.should have_tag('a[href=/days]')
  end
  
  it "should have the label 'Index' by default" do
    markup = @view.index_days
    markup.should have_tag('a', 'Index')
  end
  
  it "should allow passing in a custom label" do
    @view.should_receive(:days_path).and_return('/days')
    markup = @view.index_days(:label => 'Back')
    markup.should have_tag('a', 'Back')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.index_days(:title => 'Click to list')
    markup.should have_tag('a[title=Click to list]')
  end
  
  it "should pass additional options on to the named route helper" do
    @view.should_receive(:days_path).with(:my_param => 'my-value').and_return('/days?my_param=my-value')
    markup = @view.index_days(:label => 'Back', :my_param => 'my-value')
    markup.should have_tag('a[href=/days?my_param=my-value]')
  end
  
end


describe 'index_resource with plural nested resource' do
  
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

  it "should create a link with resourceful classes" do
    markup = @view.index_day_hours(@day)
    markup.should have_tag('a.index.hours.index_hours')
  end
  
  it "should allow adding custom classes" do
    markup = @view.index_day_hours(@day, :class => 'search')
    markup.should have_tag('a.index.hours.search.index_hours.search_hours')
  end
  
  it "should link to the resources_path" do
    @view.should_receive(:day_hours_path).with(@day).and_return('/days/1/hours')
    markup = @view.index_day_hours(@day)
    markup.should have_tag('a[href=/days/1/hours]')
  end
  
  it "should have the label 'Index' by default" do
    markup = @view.index_day_hours(@day)
    markup.should have_tag('a', 'Index')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.index_day_hours(@day, :label => 'Back')
    markup.should have_tag('a', 'Back')
  end
  
  it "should pass additional options on to the named route helper"
  it "should allow for setting the title attribute of the link via the :title option"
  
end
