require File.dirname(__FILE__) + '/../../spec_helper'

describe "/renderings/show (js)" do
  fixtures :all
  before(:each) do
    assigns[:rendering] = renderings(:main11)
    render 'renderings/show.rjs'
  end

  it "should succeed" do
    response.should be_success
  end

  it "should update the toolbox" do
    response.body.should =~ /toolbox/
  end

  it "should update the Toolbox header" do
    response.should have_rjs(:chained_replace_html,'toolbox_header') do
      response.should have_text(/Rendering \d+/)
    end
  end

  it "should show the Rendering and its components in the toolbox" do
    response.should have_rjs(:chained_replace_html,'toolbox_content') do
      response.should have_tag('dl.rendering') do
        with_tag('dt', 'This Rendering')
        with_tag('dd') do
          with_tag('a','clone')
          with_tag('a','delete')
        end

        with_tag('dt', 'Content')
        with_tag('dd', /Welcome.*\(Document: \d+\)/m) do
          with_tag('a','edit')
          with_tag('a','select')
        end

        with_tag('dt', 'Grid - Hierarchy')
        with_tag('dd') do
          with_tag('ul') do
            with_tag('li') do
              with_tag('a', 'edit')
            end
          end
        end

        with_tag('dt', 'Part')
        with_tag('dd', /Simple Preview/m) do
          with_tag('a','edit')
          with_tag('a','select')
        end
      end
    end
  end

  it "should update the assigned rendering" do
    response.should have_rjs(:chained_replace,'rendering_42101') do
      response.should have_tag('div.rendering.document.simple_preview#rendering_42101', /Welcome/) 
    end
  end

  it "should unmark all active" do
    response.body.should have_text(%r~\$\$\("div.active"\).*value\.removeClassName.*resetBehavior~m)
  end

  it "should mark the rendering as active" do
    response.body.should have_text(%r~\$\("rendering_42101"\)\.addClassName\("active"\)~)
  end

  it "should mark the rendering's grid as active" do
    gid = renderings(:main11).grid_id
    response.body.should have_text(%r~\$\("grid_#{gid}"\)\.addClassName\("active"\)~)
  end
end
