require File.dirname(__FILE__) + '/../../spec_helper'

describe "/renderings/edit.html.erb" do
  include RenderingsHelper
  ActionView::Base.default_form_builder = NormalFormBuilder
  
  before do
    login_as :quentin
    @rendering = Factory(:rendering)
    assigns[:rendering] = @rendering
  end

  it "should render edit form" do
    render "/renderings/edit.html.erb"

    response.should be_success

    response.should have_tag("form[action=#{rendering_path(@rendering)}][method=post]") do
      with_tag('select#rendering_assignment[name=?]', 'rendering[assignment]')
      with_tag('div.scopes.Content') do
        with_tag('select[name=?]', 'rendering[scope][order]')

        with_tag('select[name=?]', 'rendering[scope][field][]')
        with_tag('select[name=?]', 'rendering[scope][comparison][]')
        with_tag('input[name=?]', 'rendering[scope][value][]')
      end
    end
  end
end


