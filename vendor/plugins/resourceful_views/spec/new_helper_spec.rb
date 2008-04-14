require File.dirname(__FILE__) + '/spec_helper'


describe 'new_resource with plural resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days
    end
    @view = ActionView::Base.new
    @view.stub!(:new_day_path).and_return('/days/new')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.new_day
    markup.should have_tag('a.new.day.new_day')
  end
  
  it "should allow adding custom classes" do
    markup = @view.new_day(:class => 'sunny')
    markup.should have_tag('a.new.day.sunny.new_day.sunny_day')
  end
  
  it "should link to the new_resource_path" do
    @view.should_receive(:new_day_path).and_return('/days/new')
    markup = @view.new_day
    markup.should have_tag('a[href=/days/new]')
  end
  
  it "should have the label 'New' by default" do
    markup = @view.new_day
    markup.should have_tag('a', 'New')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.new_day(:label => 'Add')
    markup.should have_tag('a', 'Add')
  end
  
  it "should pass additional options on to the named route helper"
  it "should allow for setting the title attribute of the link via the :title option"
  
end


describe 'new_resource with plural nested resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days do |day|
        day.resources :hours
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:new_day_hour_path).and_return('/days/1/hours/new')
    @day = mock('day')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.new_day_hour(@day)
    markup.should have_tag('a.new.hour.new_hour')
  end
  
  it "should allow adding custom classes" do
    markup = @view.new_day_hour(:class => 'night')
    markup.should have_tag('a.new.hour.night.new_hour.night_hour')
  end
  
  it "should link to the new_resource_path" do
    @view.should_receive(:new_day_hour_path).and_return('/days/1/hours/new')
    markup = @view.new_day_hour(@day)
    markup.should have_tag('a[href=/days/1/hours/new]')
  end
  
  it "should have the label 'New' by default" do
    markup = @view.new_day_hour(@day)
    markup.should have_tag('a', 'New')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.new_day_hour(@day, :label => 'Add')
    markup.should have_tag('a', 'Add')
  end
  
  it "should pass additional options on to the named route helper"
  it "should allow for setting the title attribute of the link via the :title option"
  
end


describe 'new_resource for singular nested resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :books do |book|
        book.resource :cover
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:new_book_cover_path).and_return('/books/1/cover/new')
    @book = mock('book')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.new_book_cover(@book)
    markup.should have_tag('a.new.cover.new_cover')
  end
  
  it "should allow adding custom classes" do
    markup = @view.new_book_cover(@book, :class => 'pretty')
    markup.should have_tag('a.new.cover.pretty.new_cover.pretty_cover')
  end
  
  it "should link to the new_resource_path" do
    @view.should_receive(:new_book_cover_path).with(@book).and_return('/books/1/cover/new')
    markup = @view.new_book_cover(@book)
    markup.should have_tag('a[href=/books/1/cover/new]')
  end
  
  it "should have the label 'New' by default" do
    markup = @view.new_book_cover(@book)
    markup.should have_tag('a', 'New')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.new_book_cover(@book, :label => 'Add')
    markup.should have_tag('a', 'Add')
  end
  
  it "should pass additional options on to the named route helper"
  it "should allow for setting the title attribute of the link via the :title option"
  
end