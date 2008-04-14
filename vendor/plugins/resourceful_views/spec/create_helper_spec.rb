require File.dirname(__FILE__) + '/spec_helper'


describe 'create_resource with plural resource' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days
    end
    @view = ActionView::Base.new
    @view.stub!(:days_path).and_return('/days')
  end
  
  it "should render a create resource form" do
    markup = @view.create_day
    markup.should have_tag('form.create.day.create_day')
  end
  
  it "should allow for passing in additions custom classes" do
    markup = @view.create_day({}, :class => 'sunny')
    markup.should have_tag('form.create.day.sunny.create_day.sunny_day')
  end
  
  it "should submit to resource path" do
    @view.should_receive(:days_path).and_return('/days')
    markup = @view.create_day
    markup.should have_tag('form[action=/days]')
  end
  
  it "should render hidden fields for passed-in attributes" do
    markup = @view.create_day(:weather => 'sunny', :type => 'holiday')
    markup.should have_tag('form') do
      with_tag("input[type=hidden][name='day[weather]'][value=sunny]")
      with_tag("input[type=hidden][name='day[type]'][value=holiday]")
    end
  end
  
  it "should render a submit button with default label 'Add'" do
    markup = @view.create_day
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Add')
    end
  end
  
  it "should allow passing in a custom label for the submit button" do
    markup = @view.create_day({}, :label => 'Create')
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Create')
    end
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option"
    
end


describe 'create_resource with plural resource and block' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days
    end
    @view = ActionView::Base.new
    @view.stub!(:days_path).and_return('/days')
    @view.stub!(:protect_against_forgery?).and_return(false)
  end
  
  it "should render a 'create_day' form" do
    _erbout = ''
    @view.create_day do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.day.create_day', 'some-content')
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.create_day(:class => 'sunny') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.day.create_day.sunny.sunny_day', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.create_day do |form|
       _erbout << form.text_field(:weather)
    end
    _erbout.should have_tag("form.create.day input[type=text][name='day[weather]']")
  end

end



describe 'create_resource with plural nested resource' do
  
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
  
  it "should render a create resource form" do
    markup = @view.create_day_hour(@day)
    markup.should have_tag('form.create.hour.create_hour')
  end
  
  it "should allow for passing in additions custom classes" do
    markup = @view.create_day_hour(@day, {}, :class => 'night')
    markup.should have_tag('form.create.hour.night.create_hour.night_hour')
  end
  
  it "should submit to resource path" do
    @view.should_receive(:day_hours_path).and_return('/days/1/hours')
    markup = @view.create_day_hour(@day)
    markup.should have_tag('form[action=/days/1/hours]')
  end
  
  it "should render hidden fields for passed-in attributes" do
    markup = @view.create_day_hour(@day, :type => 'night')
    markup.should have_tag('form') do
      with_tag("input[type=hidden][name='hour[type]'][value=night]")
    end
  end
  
  it "should render a submit button with default label 'Add'" do
    markup = @view.create_day_hour(@day)
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Add')
    end
  end
  
  it "should allow passing in a custom label for the submit button" do
    markup = @view.create_day_hour(@day, {}, :label => 'Create')
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Create')
    end
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option"
  
end


describe 'create_resource with plural nested resource and block' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :days do |day|
        day.resources :hours
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:day_hours_path).and_return('/days/1/hours')
    @view.stub!(:protect_against_forgery?).and_return(false)
    @day = mock('day')
  end
  
  it "should render a 'create_day' form" do
    _erbout = ''
    @view.create_day_hour(@day) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.hour.create_hour', 'some-content')
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.create_day_hour(@day, :class => 'night') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.hour.create_hour.night.night_hour', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.create_day_hour(@day) do |form|
       _erbout << form.text_field(:type)
    end
    _erbout.should have_tag("form.create_hour input[type=text][name='hour[type]']")
  end

end 



describe 'create_resource for singular nested resource' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :books do |book|
        book.resource :cover
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:book_cover_path).and_return('/books/1/cover')
    @book = mock('book')
  end
  
  it "should render a create resource form" do
    markup = @view.create_book_cover(@book)
    markup.should have_tag('form.create.cover.create_cover')
  end
  
  it "should allow for passing in additions custom classes" do
    markup = @view.create_book_cover(@book, {}, :class => 'pretty')
    markup.should have_tag('form.create.cover.pretty.create_cover.pretty_cover')
  end
  
  it "should submit to resource path" do
    @view.should_receive(:book_cover_path).and_return('/books/1/cover')
    markup = @view.create_book_cover(@book)
    markup.should have_tag('form[action=/books/1/cover]')
  end
  
  it "should render hidden fields for passed-in attributes" do
    markup = @view.create_book_cover(@book, :type => 'glossy')
    markup.should have_tag('form') do
      with_tag("input[type=hidden][name='cover[type]'][value=glossy]")
    end
  end
  
  it "should render a submit button with default label 'Add'" do
    markup = @view.create_book_cover(@book)
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Add')
    end
  end
  
  it "should allow passing in a custom label for the submit button" do
    markup = @view.create_book_cover(@book, {}, :label => 'Create')
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Create')
    end
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option"
  
end



describe 'create_resource with singular nested resource and block' do
  
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
  end
  
  it "should render a 'create_day' form" do
    _erbout = ''
    @view.create_book_cover(@book) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.cover.create_cover', 'some-content')
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.create_book_cover(@book, :class => 'pretty') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.cover.create_cover.pretty.pretty_cover', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.create_book_cover(@book) do |form|
       _erbout << form.text_field(:type)
    end
    _erbout.should have_tag("form.create_cover input[type=text][name='cover[type]']")
  end

end 

