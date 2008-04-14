require File.dirname(__FILE__) + '/spec_helper'


describe 'destroy_resource with plural resource' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days
    end
    @view = ActionView::Base.new
    @view.stub!(:day_path).and_return('/days/1')
    @day = mock('day', :to_param => 1)
  end
  
  it "should create a form with resourceful classes" do
    markup = @view.destroy_day(@day)
    markup.should have_tag('form.destroy.day.destroy_day')
  end

  it "should allow adding custom classes" do
    markup = @view.destroy_day(@day, :class => 'sunny')
    markup.should have_tag('form.destroy.day.sunny.destroy_day.sunny_day')
  end
  
  it "should submit to the resource_path" do
    @view.should_receive(:day_path).with(@day).and_return('/days/1')
    markup = @view.destroy_day(@day)
    markup.should have_tag('form[action=/days/1]')
  end
  
  it "should send the method 'delete' as a hidding field" do
    markup = @view.destroy_day(@day)
    markup.should have_tag('form input[type=hidden][name=_method][value=delete]')
  end
  
  it "should have a submit button labeled 'Delete' by default" do
    markup = @view.destroy_day(@day)
    markup.should have_tag('form button[type=submit]', 'Delete')
  end
  
  it "should allow passing in a custom label to be used for the button" do
    markup = @view.destroy_day(@day, :label => 'Remove')
    markup.should have_tag('form button[type=submit]', 'Remove')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option"
  
end



describe 'destroy_resource with plural nested resource' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days do |day|
        day.resources :hours
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:day_hour_path).and_return('/days/1/hour/1')
    @day = mock('day')
    @hour = mock('hour')
  end
  
  it "should create a form with resourceful classes" do
    markup = @view.destroy_day_hour(@day, @hour)
    markup.should have_tag('form.destroy.hour.destroy_hour')
  end

  it "should allow adding custom classes" do
    markup = @view.destroy_day_hour(@day, @hour, :class => 'night')
    markup.should have_tag('form.destroy.hour.night.destroy_hour.night_hour')
  end
  
  it "should submit to the resource_path" do
    @view.should_receive(:day_hour_path).with(@day, @hour).and_return('/days/1/hours/1')
    markup = @view.destroy_day_hour(@day, @hour)
    markup.should have_tag('form[action=/days/1/hours/1]')
  end
  
  it "should send the method 'delete' as a hidding field" do
    markup = @view.destroy_day_hour(@day, @hour)
    markup.should have_tag('form input[type=hidden][name=_method][value=delete]')
  end
  
  it "should have a submit button labeled 'Delete' by default" do
    markup = @view.destroy_day_hour(@day, @hour)
    markup.should have_tag('form button[type=submit]', 'Delete')
  end
  
  it "should allow passing in a custom label to be used for the button" do
    markup = @view.destroy_day_hour(@day, @hour, :label => 'Remove')
    markup.should have_tag('form button[type=submit]', 'Remove')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option"
  
end



describe 'destroy_resource with singular nested resource' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :books do |day|
        day.resource :cover
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:book_cover_path).and_return('/books/1/cover')
    @book = mock('book')
  end
  
  it "should create a form with resourceful classes" do
    markup = @view.destroy_book_cover(@book)
    markup.should have_tag('form.destroy.cover.destroy_cover')
  end

  it "should allow adding custom classes" do
    markup = @view.destroy_book_cover(@book, :class => 'pretty')
    markup.should have_tag('form.destroy.cover.pretty.destroy_cover.pretty_cover')
  end
  
  it "should submit to the resource_path" do
    @view.should_receive(:book_cover_path).with(@book).and_return('/books/1/cover')
    markup = @view.destroy_book_cover(@book)
    markup.should have_tag('form[action=/books/1/cover]')
  end
  
  it "should send the method 'delete' as a hidding field" do
    markup = @view.destroy_book_cover(@book)
    markup.should have_tag('form input[type=hidden][name=_method][value=delete]')
  end
  
  it "should have a submit button labeled 'Delete' by default" do
    markup = @view.destroy_book_cover(@book)
    markup.should have_tag('form button[type=submit]', 'Delete')
  end
  
  it "should allow passing in a custom label to be used for the button" do
    markup = @view.destroy_book_cover(@book, :label => 'Remove')
    markup.should have_tag('form button[type=submit]', 'Remove')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option"
  
end

