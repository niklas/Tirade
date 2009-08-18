require File.dirname(__FILE__) + '/../../spec_helper'

describe "/parts/edit.html.erb" do
  include PartsHelper
  ActionView::Base.default_form_builder = NormalFormBuilder
  
  before do
    @part = Factory(:part)
    assigns[:part] = @part
  end

  it "should render edit form" do
    render "/parts/edit.html.erb"
    
    response.should have_tag("form[action=#{part_path(@part)}][method=post]") do
      with_tag('input#part_name[name=?]', "part[name]")
      with_tag("textarea#part_liquid[name=?]", "part[liquid]")
    end
  end
end


