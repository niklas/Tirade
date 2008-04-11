require File.dirname(__FILE__) + '/../../spec_helper'

describe "/grids/show" do
  before(:each) do
    assigns[:grid] = Grid.new
    render 'grids/show'
  end
  
  it "should have at least a div" do
    response.should have_tag('div')
  end
end
