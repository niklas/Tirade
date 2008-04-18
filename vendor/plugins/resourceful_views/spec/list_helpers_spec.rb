require File.dirname(__FILE__) + '/spec_helper'

describe 'resource_list' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
  end
  
  it "should render a unordered list with CLASS 'resource_list'" do
    _erbout = ''
    @view.table_list do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('ul.table_list', 'some-content')
  end
  
  it "should allow passing in additional classnames" do
    _erbout = ''
    @view.table_list(:class => 'dining') do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('ul.table_list.dining.dining_table_list', 'some-content')
  end
  
end


describe 'the_resource_list' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
  end
  
  it "should render a unordered list with ID 'resource_list'" do
    _erbout = ''
    @view.the_table_list do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('ul#table_list', 'some-content')
  end
  
end


describe 'ordered_resource_list' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
  end
  
  it "should render a ordered list with CLASS 'resource_list'" do
    _erbout = ''
    @view.ordered_table_list do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('ol.table_list', 'some-content')
  end
  
end


describe 'the_ordered_resource_list' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
  end
  
  it "should render a ordered list with ID 'resource_list'" do
    _erbout = ''
    @view.the_ordered_table_list do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('ol#table_list', 'some-content')
  end
  
end






