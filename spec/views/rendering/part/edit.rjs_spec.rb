require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/rendering/part/edit (js)" do
  fixtures :all
  before(:each) do
    assigns[:rendering] = renderings(:main11)
    assigns[:part] = renderings(:main11).part
    render 'rendering/part/edit.rjs'
  end

  it "should be successfull" do
    response.should be_success
  end

  it "should set the toolbox header" do
    response.should set_toolbox_header(/Edit Part \d+/)
  end

  it "should not offer to edit the name/filename?"

  it "should offer a nice way to define the options with acts_as_custom_configurable"

  it "should be switchable between theme and vendor version"

  it "should render the part form in the toolbox" do
    response.should have_rjs(:chained_replace_html,'toolbox_content') do
      response.should have_tag('div.warning')
      response.should have_tag('form.part.update') do
        # FIXME really show the name/filename, editable??
        with_tag('input[type=text][name=?]', 'part[name]')
        with_tag('input[type=text][name=?]', 'part[filename]')
        with_tag('textarea[name=?]', 'part[rhtml]')
        with_tag('input[type=hidden][name=rendering_id]')
        with_tag('a', 'cancel')
      end
    end
  end
end

