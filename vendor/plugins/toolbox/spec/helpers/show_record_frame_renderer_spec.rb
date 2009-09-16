require File.dirname(__FILE__) + '/../spec_helper'

describe ShowRecordFrameRenderer do
  subject do
    @record = Factory :document
    ShowRecordFrameRenderer.new(@record, helper)
  end
  before( :each ) do
    stubs_for_helper
  end
  it_should_behave_like 'every FrameRenderer'

  it "should add resource identifier and metadata to div" do
    html.should have_tag("div.frame.document.document_#{@record.id}[data]")
  end

  it "should generate options to render" do
    subject.render_options.should == {
      :object => @record,
      :locals => {
        :document => @record
      },
      :layout => '/layouts/toolbox',
      :partial => 'show'
    }
  end

  it "should generate metadata" do
    controller.stub!(:action_name).and_return('show')
    subject.meta.should === {
      :action => 'show',
      :id => @record.id,
      :resource_name => 'document',
      :controller => 'helper_example_group',
      :title => @record.title,
      :href => 'http://test.host/'
    }
  end

  it "should present CSS classes for record" do
    css = subject.css
    css.should include('document')
    css.should include("document_#{@record.id}")
  end

  it "should have link to edit record" do
    subject.links.should include('[Edit Link]')
  end
  it "should have link to destroy record" do
    subject.links.should include('[Destroy Link]')
  end
end

