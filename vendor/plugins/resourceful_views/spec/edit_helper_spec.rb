require File.dirname(__FILE__) + '/spec_helper'


describe 'edit_resource with plural resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days
    end
    @view = ActionView::Base.new
    @view.stub!(:edit_day_path).and_return('/days/1/edit')
    @day = mock('day', :to_param => 1)
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.edit_day(@day)
    markup.should have_tag('a.edit.day.edit_day')
  end
  
  it "should allow adding custom classes" do
    markup = @view.edit_day(@day, :class => 'sunny')
    markup.should have_tag('a.edit.day.sunny.edit_day.sunny_day')
  end
  
  it "should link to the edit_resource_path" do
    @view.should_receive(:edit_day_path).with(@day).and_return('/days/1/edit')
    markup = @view.edit_day(@day)
    markup.should have_tag('a[href=/days/1/edit]')
  end
  
  it "should have the label 'Edit' by default" do
    markup = @view.edit_day(@day)
    markup.should have_tag('a', 'Edit')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.edit_day(@day, :label => 'Change')
    markup.should have_tag('a', 'Change')
  end
  
  it "should pass additional options on to the named route helper"
  it "should allow for setting the title attribute of the link via the :title option"
  
end


describe 'edit_resource with plural nested resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days do |day|
        day.resources :hours
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:edit_day_hour_path).and_return('/days/1/hours/1/edit')
    @day = mock('day')
    @hour = mock('hour')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.edit_day_hour(@day, @hour)
    markup.should have_tag('a.edit.hour.edit_hour')
  end
  
  it "should allow adding custom classes" do
    markup = @view.edit_day_hour(@day, @hour, :class => 'night')
    markup.should have_tag('a.edit.hour.night.edit_hour.night_hour')
  end
  
  it "should link to the edit_resource_path" do
    @view.should_receive(:edit_day_hour_path).with(@day, @hour).and_return('/days/1/hours/1/edit')
    markup = @view.edit_day_hour(@day, @hour)
    markup.should have_tag('a[href=/days/1/hours/1/edit]')
  end
  
  it "should have the label 'Edit' by default" do
    markup = @view.edit_day_hour(@day, @hour)
    markup.should have_tag('a', 'Edit')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.edit_day_hour(@day, @hour, :label => 'Change')
    markup.should have_tag('a', 'Change')
  end
  
  it "should pass additional options on to the named route helper"
  it "should allow for setting the title attribute of the link via the :title option"
  
end  



describe 'edit_resource for singular nested resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :books do |book|
        book.resource :cover
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:edit_book_cover_path).and_return('/books/1/cover/edit')
    @book = mock('book')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.edit_book_cover(@book)
    markup.should have_tag('a.edit.cover.edit_cover')
  end
  
  it "should allow adding custom classes" do
    markup = @view.edit_book_cover(@book, :class => 'pretty')
    markup.should have_tag('a.edit.cover.pretty.edit_cover.pretty_cover')
  end
  
  it "should link to the edit_resource_path" do
    @view.should_receive(:edit_book_cover_path).with(@book).and_return('/books/1/cover/edit')
    markup = @view.edit_book_cover(@book) 
    markup.should have_tag('a[href=/books/1/cover/edit]')
  end
  
  it "should have the label 'Edit' by default" do
    markup = @view.edit_book_cover(@book) 
    markup.should have_tag('a', 'Edit')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.edit_book_cover(@book, :label => 'Change')
    markup.should have_tag('a', 'Change')
  end
  
  it "should pass additional options on to the named route helper"
  it "should allow for setting the title attribute of the link via the :title option"
  
end

