require File.dirname(__FILE__) + '/spec_helper'


describe 'new_resource with plural resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:new_table_path).and_return('/tables/new')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.new_table
    markup.should have_tag('a.new.table.new_table')
  end
  
  it "should allow adding custom classes" do
    markup = @view.new_table(:class => 'dining')
    markup.should have_tag('a.new.table.dining.new_table.dining_table')
  end
  
  it "should link to the new_resource_path" do
    @view.should_receive(:new_table_path).and_return('/tables/new')
    markup = @view.new_table
    markup.should have_tag('a[href=/tables/new]')
  end
  
  it "should have the label 'New' by default" do
    markup = @view.new_table
    markup.should have_tag('a', 'New')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.new_table(:label => 'Add')
    markup.should have_tag('a', 'Add')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.new_table(:title => 'Click to create new')
    markup.should have_tag('a[title=Click to create new]')
  end
  
  it "should pass additional options on to the named route helper" do
    @view.should_receive(:new_table_path).with(:my_param => 'my_value').and_return('/tables/new?my_param=my_value')
    markup = @view.new_table(:my_param => 'my_value')
    markup.should have_tag('a[href=/tables/new?my_param=my_value]')
  end
  
end


describe 'new_resource with plural nested resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:new_table_leg_path).and_return('/tables/1/legs/new')
    @table = mock('table')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.new_table_leg(@table)
    markup.should have_tag('a.new.leg.new_leg')
  end
  
  it "should allow adding custom classes" do
    markup = @view.new_table_leg(:class => 'metal')
    markup.should have_tag('a.new.leg.metal.new_leg.metal_leg')
  end
  
  it "should link to the new_resource_path" do
    @view.should_receive(:new_table_leg_path).and_return('/tables/1/legs/new')
    markup = @view.new_table_leg(@table)
    markup.should have_tag('a[href=/tables/1/legs/new]')
  end
  
  it "should have the label 'New' by default" do
    markup = @view.new_table_leg(@table)
    markup.should have_tag('a', 'New')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.new_table_leg(@table, :label => 'Add')
    markup.should have_tag('a', 'Add')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.new_table_leg(@table, :title => 'Click to create new')
    markup.should have_tag('a[title=Click to create new]')
  end
  
  it "should pass additional options on to the named route helper" do
    @view.should_receive(:new_table_leg_path).with(@table, :my_param => 'my_value').and_return('/tables/1/legs/new?my_param=my_value')
    markup = @view.new_table_leg(@table, :my_param => 'my_value')
    markup.should have_tag('a[href=/tables/1/legs/new?my_param=my_value]')
  end
  
end


describe 'new_resource for singular nested resource' do

  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resource :top
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:new_table_top_path).and_return('/tables/1/top/new')
    @table = mock('table')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.new_table_top(@table)
    markup.should have_tag('a.new.top.new_top')
  end
  
  it "should allow adding custom classes" do
    markup = @view.new_table_top(@table, :class => 'wood')
    markup.should have_tag('a.new.top.wood.new_top.wood_top')
  end
  
  it "should link to the new_resource_path" do
    @view.should_receive(:new_table_top_path).with(@table).and_return('/tables/1/top/new')
    markup = @view.new_table_top(@table)
    markup.should have_tag('a[href=/tables/1/top/new]')
  end
  
  it "should have the label 'New' by default" do
    markup = @view.new_table_top(@table)
    markup.should have_tag('a', 'New')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.new_table_top(@table, :label => 'Add')
    markup.should have_tag('a', 'Add')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.new_table_top(@table, :title => 'Click to create new')
    markup.should have_tag('a[title=Click to create new]')
  end
  
  it "should pass additional options on to the named route helper" do
    @view.should_receive(:new_table_top_path).with(@table, :my_param => 'my_value').and_return('/tables/1/top/new?my_param=my_value')
    markup = @view.new_table_top(@table, :my_param => 'my_value')
    markup.should have_tag('a[href=/tables/1/top/new?my_param=my_value]')
  end
  
end