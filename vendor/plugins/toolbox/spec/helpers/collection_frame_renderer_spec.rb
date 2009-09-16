require File.dirname(__FILE__) + '/../spec_helper'

describe CollectionFrameRenderer do
  subject do
    5.times { Factory :document }
    @collection = Document.all
    CollectionFrameRenderer.new(@collection, helper)
  end
  before( :each ) do
    stubs_for_helper
  end

  it_should_behave_like 'every FrameRenderer'

  it "should add resource identifier and metadata to div" do
    html.should have_tag("div.frame.index.document[data]")
  end

  it "should generate options to render" do
    subject.render_options.should == {
      :object => @collection,
      :locals => {
        :documents => @collection
      },
      :layout => '/layouts/toolbox',
      :partial => 'list'
    }
  end

  it "should generate metadata" do
    controller.stub!(:action_name).and_return('index')
    subject.meta.should === {
      :action => 'index',
      :resource_name => 'document',
      :controller => 'helper_example_group',
      :title => 'Documents',
      :href => 'http://test.host/'
    }
  end

  it "should present CSS classes for record" do
    css = subject.css
    css.should include('index')
    css.should include('document')
  end

  it "should have link to create record" do
    subject.links.should include('[New Link]')
  end
end

