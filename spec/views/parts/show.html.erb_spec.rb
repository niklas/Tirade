require File.dirname(__FILE__) + '/../../spec_helper'

describe "/parts/show.html.erb" do
  include PartsHelper
  
  before(:each) do
    @part = mock_model(Part)
    @part.stub!(:name).and_return("MyString")
    @part.stub!(:filename).and_return("MyString")
    @part.stub!(:options).and_return("MyText")
    @part.stub!(:preferred_types).and_return(['Foo', 'Bar'])
    @part.stub!(:rhtml).and_return("<p>My RHTML</p>")
    @part.stub!(:in_theme?).and_return(false)

    assigns[:part] = @part
  end

  it "should render attributes in <p>" do
    render "/parts/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyText/)
    response.should have_text(/MyText/)
  end
end

