require File.dirname(__FILE__) + '/spec_helper'


describe 'search_resource with plural resource' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:tables_path).and_return('/tables')
  end
  
  it "should render a form GETTing to the resource path" do
    markup = @view.search_tables
    markup.should have_tag('form[action=/tables][method=get]')
  end
  
  it "should render a search_resource form" do
    markup = @view.search_tables
    markup.should have_tag('form.search.tables.search_tables')
  end
  
  it "should render a 'Search' submit button by default" do
    markup = @view.search_tables
    markup.should have_tag('button[type=submit]', 'Search')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.search_tables(:label => 'Find')
    markup.should have_tag('button[type=submit]', 'Find')
  end
  
  it "should render a text field for the query" do
    markup = @view.search_tables
    markup.should have_tag('input[type=text][name=query]')
  end
  
  it "should fill in the instance variable @query as the query value" do
    pending('Trouble getting assigns to work here')
    @view.stub!(:assigns).and_return({:query => 'dining'})
    markup = @view.search_tables
    markup.should have_tag('input[type=text][name=query][value=dining]')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option" do
    markup = @view.search_tables(:title => 'Click to search')
    markup.should have_tag('button[title=Click to search]')
  end
  
end


describe 'search_resource with plural nested resource' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:table_legs_path).and_return('/tables/1/legs')
    @table = mock('table')
  end
  
  it "should render a form GETTing to the resource path" do
    markup = @view.search_table_legs(@table)
    markup.should have_tag('form[action=/tables/1/legs][method=get]')
  end
  
  it "should render a search_resource form" do
    markup = @view.search_table_legs(@table)
    markup.should have_tag('form.search.legs.search_legs')
  end
  
  it "should render a 'Search' submit button by default" do
    markup = @view.search_table_legs(@table)
    markup.should have_tag('button[type=submit]', 'Search')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.search_table_legs(@table, :label => 'Find')
    markup.should have_tag('button[type=submit]', 'Find')
  end
  
  it "should render a text field for the query" do
    markup = @view.search_table_legs(@table)
    markup.should have_tag('input[type=text][name=query]')
  end
  
  it "should fill in the instance variable @query as the query value" do
    pending('Trouble getting assigns to work here')
    @view.stub!(:assigns).and_return({:query => 'dining'})
    markup = @view.search_table_legs(@table)
    markup.should have_tag('input[type=text][name=query][value=dining]')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option" do
    markup = @view.search_table_legs(:title => 'Click to search')
    markup.should have_tag('button[title=Click to search]')
  end
  
end

