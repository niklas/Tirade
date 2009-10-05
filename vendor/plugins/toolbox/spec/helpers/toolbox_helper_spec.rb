require File.dirname(__FILE__) + '/../spec_helper'


describe ToolboxHelper do

  before( :each ) do
    stubs_for_helper
    @document = Factory(:document)
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
    ShowRecordFrameRenderer.should_receive(:new).with(@document, helper, {}).and_return(
      mock(ShowRecordFrameRenderer, :html => 'show record')
    )
    helper.frame_for(@document).should == 'show record'
  end

  it "should build a frame to edit a record" do
    EditRecordFrameRenderer.should_receive(:new).with(@document, helper, {}).and_return(
      mock(EditRecordFrameRenderer, :html => 'edit record')
    )
    helper.frame_for(@document, 'edit').should == 'edit record'
  end

  it "should build a frame to create a record (given new record)" do
    document = Factory.build(:document)
    EditRecordFrameRenderer.should_receive(:new).with(document, helper, {}).and_return(
      mock(EditRecordFrameRenderer, :html => 'new record')
    )
    helper.frame_for(document, 'edit').should == 'new record'
  end

  it "should build a frame for a collection" do
    5.times { Factory(:document) }
    all_documents = Document.all
    CollectionFrameRenderer.should_receive(:new).with(all_documents, helper, {}).and_return(
      mock(CollectionFrameRenderer, :html => 'list of records')
    )
    helper.frame_for(all_documents).should == 'list of records'
  end

  it "should build a frame using suplied partial" do
    document = Factory.build(:document)
    EditRecordFrameRenderer.should_receive(:new).with(document, helper, {:partial => 'special_documents/form'}).and_return(
      mock(EditRecordFrameRenderer, :html => 'special form')
    )
    helper.frame_for(document, 'form', :partial => 'special_documents/form').should == 'special form'
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
    helper.stub!(:frame_renderer_for).and_return( mock(:html => "Frame with collection") )
    rjs_for.push_frame_for(Document.all).should == %Q[Toolbox.push("Frame with collection");]
  end


  it "should build frame for error" do
    error = mock(ActionView::TemplateError)
    ApplicationController.stub!(:rescue_templates).and_return('Spec::Mocks::Mock' => 'template_error')
    ExceptionFrameRenderer.should_receive(:new).with(error, helper).and_return(
      mock(ExceptionFrameRenderer, :html => 'error')
    )
    helper.frame_for_error(error).should == 'error'
  end


end

