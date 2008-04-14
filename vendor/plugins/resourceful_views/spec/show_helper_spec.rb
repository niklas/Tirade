require File.dirname(__FILE__) + '/spec_helper'


describe 'show_resource with plural resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days
    end
    @view = ActionView::Base.new
    @view.stub!(:day_path).and_return('/days/1')
    @day = mock('day', :to_param => 1)
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.show_day(@day)
    markup.should have_tag('a.show.day.show_day')
  end
  
  it "should allow adding custom classes" do
    markup = @view.show_day(@day, :class => 'sunny')
    markup.should have_tag('a.show.day.sunny.show_day.sunny_day')
  end
  
  it "should link to the resource_path" do
    @view.should_receive(:day_path).with(@day).and_return('/days/1')
    markup = @view.show_day(@day)
    markup.should have_tag('a[href=/days/1]')
  end
  
  it "should have the label 'Show' by default" do
    markup = @view.show_day(@day)
    markup.should have_tag('a', 'Show')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.show_day(@day, :label => 'Details')
    markup.should have_tag('a', 'Details')
  end
  
  it "should pass additional options on to the named route helper"
  it "should allow for setting the title attribute of the link via the :title option"
  
end


describe 'show_resource with plural nested resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days do |day|
        day.resources :hours
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:day_hour_path).and_return('/days/1/hours/1')
    @day = mock('day')
    @hour = mock('hour')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.show_day_hour(@day, @hour)
    markup.should have_tag('a.show.hour.show_hour')
  end
  
  it "should allow adding custom classes" do
    markup = @view.show_day_hour(@day, @hour, :class => 'night')
    markup.should have_tag('a.show.hour.night.show_hour.night_hour')
  end
  
  it "should link to the resource_path" do
    @view.should_receive(:day_hour_path).with(@day, @hour).and_return('/days/1/hours/1')
    markup = @view.show_day_hour(@day, @hour)
    markup.should have_tag('a[href=/days/1/hours/1]')
  end
  
  it "should have the label 'Show' by default" do
    markup = @view.show_day_hour(@day, @hour)
    markup.should have_tag('a', 'Show')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.show_day_hour(@day, @hour, :label => 'Details')
    markup.should have_tag('a', 'Details')
  end
  
  it "should pass additional options on to the named route helper"
  it "should allow for setting the title attribute of the link via the :title option"
  
end


describe 'show_resource for singular nested resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :books do |book|
        book.resources :pages
        book.resource :cover
      end
    end
    @view = ActionView::Base.new
    @book = mock('book')
    @cover = mock('cover')
    @view.stub!(:book_cover_path).and_return('/book/1/cover')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.show_book_cover(@book)
    markup.should have_tag('a.show.cover.show_cover')
  end
  
  it "should allow adding custom classes" do 
    markup = @view.show_book_cover(@book, :class => 'pretty')
    markup.should have_tag('a.show.cover.pretty.show_cover.pretty_cover')
  end
  
  it "should link to the resource_path" do    
    @view.should_receive(:book_cover_path).with(@book).and_return('/book/1/cover')
    markup = @view.show_book_cover(@book)
    markup.should have_tag('a[href=/book/1/cover]')
  end
  
  it "should have the label 'Show' by default" do
    markup = @view.show_book_cover(@book)
    markup.should have_tag('a', 'Show')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.show_book_cover(@book, :label => 'Details')
    markup.should have_tag('a', 'Details')
  end
  
  it "should pass additional options on to the named route helper"
  it "should allow for setting the title attribute of the link via the :title option"
  
end

