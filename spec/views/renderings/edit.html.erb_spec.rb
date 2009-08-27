require File.dirname(__FILE__) + '/../../spec_helper'

describe "/renderings/edit.html.erb" do
  include RenderingsHelper
  ActionView::Base.class_eval do
    self.default_form_builder = NormalFormBuilder
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
    pending("think about how to define the scopes")
    response.should have_tag("form[action=#{rendering_path(@rendering)}][method=post]") do
      with_tag('select#rendering_assignment[name=?]', 'rendering[assignment]')
      with_tag('div.scopes.Content') do
        with_tag('select[name=?]', 'rendering[scope][order]')
        with_tag('.define') do
          with_tag('a.add')
          with_tag('select[name=?]', 'select_column')
          with_tag('select[name=?]', 'select_comparison')
          with_tag('.create_scope')
        end
        with_tag('div.pool') do
          with_tag('input[name=?]', 'rendering[scope][position_equals]')
          with_tag('input[name=?]', 'rendering[scope][position_greater_than]')
          with_tag('input[name=?]', 'rendering[scope][position_less_than]')
          with_tag('input[name=?]', 'rendering[scope][title_equals]')
          with_tag('input[name=?]', 'rendering[scope][title_begins_with]')
          with_tag('input[name=?]', 'rendering[scope][title_ends_with]')
        end
      end
    end
  end
end


