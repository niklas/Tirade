require File.dirname(__FILE__) + '/../spec_helper'

describe ExceptionFrameRenderer do
  subject { ExceptionFrameRenderer.new(@exception, helper) }
  before( :each ) do
    stubs_for_helper
    @exception = mock(Exception)
    controller.stub!(:rescue_templates).and_return('Spec::Mocks::Mock' => 'template_error')
  end

  it_should_behave_like 'every FrameRenderer'

  it "should add class 'error' to div" do
    html.should have_tag('div.frame.error[data]')
  end

  it "should generate options to render" do
    subject.render_options.should == {
      :object => @exception,
      :layout => '/layouts/toolbox',
      :partial => '/toolbox/template_error'
    }
  end

  it "should generate metadata" do
    controller.stub!(:action_name).and_return('new')
    subject.meta.should == {
      :action => 'new',
      :resource_name => 'document',
      :controller => 'helper_example_group',
      :title => 'Spec::Mocks::Mock',
      :href => 'http://test.host/'
    }
  end

  it "should present CSS classes for record" do
    css = subject.css
    css.should include('error')
    css.should include('exception')
  end

  it "should have link to OK" do
    subject.links.should include('[OK Link]')
  end
end

