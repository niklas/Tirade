require File.dirname(__FILE__) + '/../../spec_helper'

describe "/parts/index.html.erb" do
  include PartsHelper
  
  before(:each) do
    part_98 = mock_model(Part)
    part_98.should_receive(:name).and_return("MyString")
    part_98.should_receive(:filename).and_return("MyString")
    part_98.should_receive(:options).and_return("MyText")
    part_98.should_receive(:preferred_types).and_return("MyText")
    part_99 = mock_model(Part)
    part_99.should_receive(:name).and_return("MyString")
    part_99.should_receive(:filename).and_return("MyString")
    part_99.should_receive(:options).and_return("MyText")
    part_99.should_receive(:preferred_types).and_return("MyText")

    assigns[:parts] = [part_98, part_99]
  end

  it "should render list of parts" do
    render "/parts/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyText", 2)
    response.should have_tag("tr>td", "MyText", 2)
  end
end

