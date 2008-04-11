require File.dirname(__FILE__) + '/../spec_helper'

describe Grid do
  before(:each) do
    @grid = Grid.new
  end

  it "should_not be valid" do
    @grid.should_not be_valid
  end

  it "should be valid if we set a grid_class" do
    @grid.grid_class = Grid::Types.keys.first
    @grid.should be_valid
  end
end
