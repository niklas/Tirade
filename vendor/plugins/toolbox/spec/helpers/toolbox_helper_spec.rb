require File.dirname(__FILE__) + '/../spec_helper'


describe ToolboxHelper do

  before( :each ) do
    helper.stub!(:render).and_return("stubbed render call")
    @document = Factory(:document)
    helper.stub!(:human_name).and_return('Documents')
    helper.stub!(:resource_name).and_return('document')
  end

  it "should help to select a frame by controller and action" do
    rjs_for.select_frame('controller', 'action').should == %Q[Toolbox.frames(":resource(controller/action)");]
  end

  it "should help to select a frame by controller, using index as default action" do
    rjs_for.select_frame('controller').should == %Q[Toolbox.frames(":resource(controller/index)");]
  end

  it "should help to select a frame for a record to show it" do
    rjs_for.select_frame_for(@document).should == %Q[Toolbox.frames(".document_#{@document.id}:resource(documents/show)");]
  end

  it "should help to select a frame for a record to edit it" do
    rjs_for.select_frame_for(@document, 'edit').should == %Q[Toolbox.frames(".document_#{@document.id}:resource(documents/edit)");]
  end

  it "should build a frame to show a record" do
    helper.frame_for(@document).should have_tag("div.frame.document.document_#{@document.id}[data]")
  end

  it "should build a frame to edit a record" do
    helper.frame_for(@document, 'form').should have_tag("div.frame.document_#{@document.id}[data]")
  end


  it "should build a frame to create a record (given new record)" do
    document = Factory.build(:document)
    helper.frame_for(document, 'form', :title => 'New Document').should have_tag("div.frame.document.new_document[data]")
  end

  it "should build a frame for a collection" do
    5.times { Factory(:document) }
    all_documents = Document.all
    helper.frame_for(all_documents, 'list').should have_tag("div.frame.index.document[data]")
  end

  it "should help to push a frame to toolbox to show a record" do
    helper.stub!(:frame_for).and_return('Frame Content')
    rjs_for.push_frame_for(@document).should == %Q[Toolbox.push("Frame Content");]
  end

  it "should help to update a frame for a record" do
    helper.stub!(:frame_renderer_for).and_return( mock(:inner => "Frame Content", :meta => {}) )
    rjs = rjs_for.update_frame_for(@document)
    rjs.should include(%Q[Toolbox.frames(".document_#{@document.id}:resource(documents/show)").html("Frame Content")])
    rjs.should include(%Q[.attr("data"])
    rjs.should include(%Q[.trigger("toolbox.frame.refresh")])
  end

  it "should help to push a frame for a collection" do
    5.times { Factory(:document) }
    helper.stub!(:frame_renderer_for).and_return( mock(:to_s => "Frame with collection") )
    rjs_for.push_frame_for(Document.all).should == %Q[Toolbox.push("Frame with collection");]
  end


  it "should build frame for error" do
    error = mock(ActionView::TemplateError)
    ApplicationController.stub!(:rescue_templates).and_return('Spec::Mocks::Mock' => 'template_error')
    helper.should_receive(:render).with(
      :partial => '/toolbox/template_error',
      :object => error,
      :layout => '/layouts/toolbox'
    ).and_return('error')
    helper.frame_for_error(error).should have_tag('div.frame.error[data]')
  end


end

