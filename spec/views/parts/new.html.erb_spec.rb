require File.dirname(__FILE__) + '/../../spec_helper'

describe "/parts/new.html.erb" do
  ActionView::Base.default_form_builder = NormalFormBuilder
  include PartsHelper
  
  before(:each) do
    @part = mock_model(Part)
    @part.stub!(:new_record?).and_return(true)
    @part.stub!(:markup?).and_return(false)
    @part.stub!(:name).and_return("MyString")
    @part.stub!(:filename).and_return("MyString")
    @part.stub!(:options_as_yaml).and_return("MyText")
    @part.stub!(:preferred_types).and_return("MyText")
    @part.stub!(:rhtml).and_return("<p>My RHTML</p>")
    @part.stub!(:in_theme?).and_return(false)
    @part.stub!(:use_theme).and_return(false)
    assigns[:part] = @part
  end

  it "should render new form" do
    render "/parts/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", parts_path) do
      with_tag("input#part_name[name=?]", "part[name]")
      with_tag("input#part_filename[name=?]", "part[filename]")
      with_tag("textarea#part_rhtml[name=?]", "part[rhtml]")
      with_tag("div#preview")
    end
  end
end


