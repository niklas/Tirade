require File.dirname(__FILE__) + '/../../spec_helper'

describe "/renderings/edit.html.erb" do
  include RenderingsHelper
  ActionView::Base.class_eval do
    self.default_form_builder = ToolboxFormBuilder
    include InterfaceHelper
  end
  
  before do
    login_with_group :admin_renderings
    login_standard
    @rendering = Factory(:rendering)
    assigns[:rendering] = @rendering
    render "/renderings/edit.html.erb"
  end

  it "should be success" do
    response.should be_success
  end

  it "should render edit form" do
    response.should have_tag("form[action=#{rendering_path(@rendering)}][method=post]") do
      with_tag('select#rendering_assignment[name=?]', 'rendering[assignment]')
      with_tag('di.define_scope dd') do
        with_tag('div.scope.blueprint') do
          with_tag('select.scope_attribute') do
            without_tag('option')
          end
          with_tag('select.scope_comparison') do
            without_tag('option')
          end
          with_tag('input.scope_value[type=text][name=?]', 'rendering[scope_definition][attribute][comparison]')
        end
      end
    end
  end
end


