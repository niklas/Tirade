require File.dirname(__FILE__) + '/../../spec_helper'

describe "/parts/edit.html.erb" do
  include PartsHelper
  
  before do
    @part = mock_model(Part)
    @part.stub!(:name).and_return("MyString")
    @part.stub!(:filename).and_return("MyString")
    @part.stub!(:options_as_yaml).and_return("MyText")
    @part.stub!(:preferred_types).and_return(['Foo', 'Bar'])
    @part.stub!(:rhtml).and_return("<p>My RHTML</p>")
    @part.stub!(:in_theme?).and_return(false)
    @part.stub!(:use_theme).and_return(false)
    assigns[:part] = @part
  end

  it "should render edit form" do
    render "/parts/edit.html.erb"
    
    response.should have_tag("form[action=#{part_path(@part)}][method=post]") do
      with_tag('input#part_name[name=?]', "part[name]")
      with_tag('input#part_filename[name=?]', "part[filename]")
      with_tag("textarea#part_rhtml[name=?]", "part[rhtml]")
      with_tag("div#preview")
    end
  end
end


