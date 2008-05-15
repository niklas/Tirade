require File.dirname(__FILE__) + '/../../spec_helper'

describe "/renderings/edit (js)" do
  fixtures :all
  before(:each) do
    assigns[:rendering] = renderings(:main11)
    render 'renderings/edit.rjs'
  end

  it "should succeed" do
    response.should be_success
  end

  it "should update the toolbox" do
    response.body.should =~ /toolbox/
  end

  it "should update the Toolbox header" do
    response.should set_toolbox_header(/Edit Rendering 42101/)
  end

  it "should show the Rendering form in the toolbox" do
    response.should have_rjs(:chained_replace_html,'toolbox_content') do
      response.should have_tag('form') do
        with_tag('input#search')
      end
      response.should have_tag('ul#search_results')
      response.should have_tag('form.rendering.update') do
        with_tag('select[name=?]', 'rendering[content_type]') do
          with_tag('option[value=Document]', 'Document')
          with_tag('option[value=NewsFolder]', 'NewsFolder')
          with_tag('option[value=Image]', 'Image')
        end
        with_tag('input[type=text][name=?]', 'rendering[content_id]')
        with_tag('select[name=?]', 'rendering[part_id]') do
          with_tag('option', 'Simple Preview')
          with_tag('option', 'Basic Calculation')
        end
        with_tag('a', 'cancel')
      end
    end
  end

  it "should unmark all active" do
    response.body.should deactivate_all
  end

  it "should mark the rendering as active" do
    response.body.should activate_dom_id("rendering_42101")
  end

  it "should not mark the other rendering as active" do
    response.body.should_not activate_dom_id("rendering_42102")
  end

  it "should mark the rendering's grid as active" do
    gid = renderings(:main11).grid_id
    response.body.should activate_dom_id("grid_#{gid}")
  end
end

