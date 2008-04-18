require File.dirname(__FILE__) + '/../../spec_helper'

describe "/grids/edit" do
  before(:each) do
    assigns[:grid] = Grid.new
    render 'grids/edit.rjs'
  end

  it "should succeed" do
    response.should be_success
  end
end
