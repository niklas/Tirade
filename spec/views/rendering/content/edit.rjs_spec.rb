require File.dirname(__FILE__) + '/../../../spec_helper'

describe '/rendering/content/edit (js)' do
  fixtures :all
  before(:each) do
    assigns[:rendering] = renderings(:main11)
    assigns[:content] = contents(:welcome)
    render 'rendering/content/edit.rjs'
  end

  it "should succeed" do
    response.should be_success
  end

  it "should set the toolbox header" do
    response.should set_toolbox_header(/Edit Welcome/)
  end

  it "should show the form in the toolbox" do
    response.should have_rjs(:chained_replace_html,'toolbox_content') do
      response.should have_tag('div.warning')
      response.should have_tag('form.content.update') do
        with_tag('input[type=text][name=?]', 'content[title]')
        with_tag('input[type=hidden][name=rendering_id]')
        with_tag('a', 'cancel')
      end
    end
  end

end

