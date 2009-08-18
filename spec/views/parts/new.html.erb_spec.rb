require File.dirname(__FILE__) + '/../../spec_helper'

describe "/parts/new.html.erb" do
  ActionView::Base.default_form_builder = NormalFormBuilder
  include PartsHelper
  
  before(:each) do
    @part = Factory.build(:part)
    assigns[:part] = @part
  end

  it "should render new form" do
    render "/parts/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", parts_path) do
      with_tag("input#part_name[name=?]", "part[name]")
      with_tag("textarea#part_liquid[name=?]", "part[liquid]")
    end
  end
end


