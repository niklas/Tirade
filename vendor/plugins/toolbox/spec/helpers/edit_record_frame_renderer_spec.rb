require File.dirname(__FILE__) + '/../spec_helper'

describe EditRecordFrameRenderer, 'for an existing document' do
  subject do
    @record = Factory :document
    EditRecordFrameRenderer.new(@record, helper)
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
      :partial => 'form'
    }
  end

  it "should generate metadata" do
    controller.stub!(:action_name).and_return('edit')
    subject.meta.should === {
      :action => 'edit',
      :id => @record.id,
      :resource_name => 'document',
      :controller => 'helper_example_group',
      :title => "Edit #{@record.title}",
      :href => 'http://test.host/'
    }
  end

  it "should present CSS classes for record" do
    css = subject.css
    css.should include('document')
    css.should include("document_#{@record.id}")
  end

  it "should have link to cancel" do
    subject.links.should include('[Cancel Link]')
  end
end

describe EditRecordFrameRenderer, 'for a new document' do
  subject do
    @record = Factory.build :document
    EditRecordFrameRenderer.new(@record, helper)
  end
  before( :each ) do
    stubs_for_helper
  end
  it_should_behave_like 'every FrameRenderer'

  it "should add resource identifier and metadata to div" do
    html.should have_tag("div.frame.document.new_document[data]")
  end

  it "should generate options to render" do
    subject.render_options.should == {
      :object => @record,
      :locals => {
        :document => @record
      },
      :layout => '/layouts/toolbox',
      :partial => 'form'
    }
  end

  it "should generate metadata" do
    controller.stub!(:action_name).and_return('new')
    subject.meta.should == {
      :action => 'new',
      :resource_name => 'document',
      :controller => 'helper_example_group',
      :title => 'new Document',
      :href => 'http://test.host/'
    }
  end

  it "should present CSS classes for record" do
    css = subject.css
    css.should include('new')
    css.should include('document')
  end

  it "should have link to cancel" do
    subject.links.should include('[Cancel Link]')
  end
end
