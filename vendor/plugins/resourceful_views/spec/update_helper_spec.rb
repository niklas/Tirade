require File.dirname(__FILE__) + '/spec_helper'


describe 'update_resource with plural resource' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days
    end
    @view = ActionView::Base.new
    @view.stub!(:day_path).and_return('/days/1')
    @day = mock('day')
  end
  
  it "should render an update_resource form" do
    markup = @view.update_day(@day)
    markup.should have_tag('form.update.day.update_day')
  end
  
  it "should allow for passing in additions custom classes" do
    markup = @view.update_day(@day, {}, :class => 'sunny')
    markup.should have_tag('form.update.day.sunny.update_day.sunny_day')
  end
  
  it "should submit to resource path" do
    @view.should_receive(:day_path).and_return('/days/1')
    markup = @view.update_day(@day)
    markup.should have_tag('form[action=/days/1]')
  end
  
  it "should use PUT method" do
    markup = @view.update_day(@day)
    markup.should have_tag('form input[type=hidden][name=_method][value=put]')
  end
  
  it "should render hidden fields for passed-in attributes" do
    markup = @view.update_day(@day, :weather => 'sunny', :type => 'holiday')
    markup.should have_tag('form') do
      with_tag("input[type=hidden][name='day[weather]'][value=sunny]")
      with_tag("input[type=hidden][name='day[type]'][value=holiday]")
    end
  end
  
  it "should render a submit button with default label 'Save'" do
    markup = @view.update_day(@day)
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Save')
    end
  end
  
  it "should allow passing in a custom label for the submit button" do
    markup = @view.update_day(@day, {}, :label => 'Update')
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Update')
    end
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option"
  
end


describe 'update_resource with plural resource and block' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days
    end
    @view = ActionView::Base.new
    @view.stub!(:day_path).and_return('/days/1')
    @view.stub!(:protect_against_forgery?).and_return(false)
    @day = mock('day', :weather => 'sunny')
  end
  
  it "should render a 'update_day' form" do
    _erbout = ''
    @view.update_day(@day) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.day.update_day', 'some-content')
  end
  
  it "should PUT to the resource path" do
    @view.should_receive(:day_path).with(@day).and_return('/days/1')
    _erbout = ''
    @view.update_day(@day) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form[action=/days/1]') do
      with_tag('input[type=hidden][name=_method][value=put]')
    end
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.update_day(@day, :class => 'sunny') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.day.update_day.sunny.sunny_day', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.update_day(@day) do |form|
       _erbout << form.text_field(:weather)
    end
    _erbout.should have_tag("form.update.day input[type=text][name='day[weather]']")
  end
  
  it "should be able to pick up the resource's attributes from the model passed as last argument" do
    @day = mock('day', :weather => 'sunny')
    _erbout = ''
    @view.update_day(@day) do |form|
       _erbout << form.text_field(:weather)
    end
    _erbout.should have_tag("input[type=text][name='day[weather]'][value=sunny]")
  end

end


describe 'update_resource with plural nested resource and block' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days do |day|
        day.resources :hours
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:day_hour_path).and_return('/days/1/hours/1')
    @view.stub!(:protect_against_forgery?).and_return(false)
    @day = mock('day')
    @hour = mock('hour')
  end
  
  it "should render a 'update_day' form" do
    _erbout = ''
    @view.update_day_hour(@day, @hour) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.hour.update_hour', 'some-content')
  end
  
  it "the 'update_day' form should submit to the day_hour path" do
    @view.should_receive(:day_hour_path).and_return('/days/1/hours/1')
    _erbout = ''
    @view.update_day_hour(@day, @hour) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update_hour[action=/days/1/hours/1]')
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.update_day_hour(@day, @hour, :class => 'night') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.hour.update_hour.night.night_hour', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.update_day_hour(@day, @hour) do |form|
       _erbout << form.text_field(:type)
    end
    _erbout.should have_tag("form.update_hour input[type=text][name='hour[type]']")
  end

end


describe 'update_resource with singular nested resource and block' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :books do |book|
        book.resource :cover
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:book_cover_path).and_return('/books/1/cover')
    @view.stub!(:protect_against_forgery?).and_return(false)
    @book = mock('book')
    @cover = mock('cover')
  end
  
  it "should render a 'update_cover' form" do
    _erbout = ''
    @view.update_book_cover(@book, @cover) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.cover.update_cover', 'some-content')
  end
  
  it "the 'update_cover' form should submit to the book_cover path" do
    @view.should_receive(:book_cover_path).and_return('/books/1/cover')
    _erbout = ''
    @view.update_book_cover(@book, @cover) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update_cover[action=/books/1/cover]')
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.update_book_cover(@book, @cover, :class => 'pretty') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.cover.update_cover.pretty.pretty_cover', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.update_book_cover(@book) do |form|
       _erbout << form.text_field(:type)
    end
    _erbout.should have_tag("form.update_cover input[type=text][name='cover[type]']")
  end
  
  it "should be able to pick up the resource's attributes when passed a model as the last argument" do
    @cover = mock('cover', :type => 'glossy')
    @book = mock('book', :cover => @cover)
    _erbout = ''
    @view.update_book_cover(@book, @book.cover) do |form|
       _erbout << form.text_field(:type)
    end
    _erbout.should have_tag("input[type=text][name='cover[type]'][value=glossy]")
  end

end