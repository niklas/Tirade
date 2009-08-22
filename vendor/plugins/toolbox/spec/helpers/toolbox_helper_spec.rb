require File.dirname(__FILE__) + '/../spec_helper'

describe ToolboxHelper do

  before( :each ) do
    helper.stub!(:render).and_return("stubbed render call")
    @document = Factory(:document)
  end

  it "should help to select a frame by controller and action" do
    rjs_for.select_frame('controller', 'action').should == %Q[Toolbox.frames(":resource(controller/action)");]
  end

  it "should help to select a frame by controller, using index as default action" do
    rjs_for.select_frame('controller').should == %Q[Toolbox.frames(":resource(controller/index)");]
  end

  it "should help to select a frame for a record to show it" do
    rjs_for.select_frame_for(@document).should == %Q[Toolbox.frames(".show.document_#{@document.id}");]
  end

  it "should help to select a frame for a record to edit it" do
    rjs_for.select_frame_for(@document, 'edit').should == %Q[Toolbox.frames(".edit.document_#{@document.id}");]
  end

  it "should build a frame to show a record" do
    helper.should_receive(:render).with(
      :partial => '/show', 
      :object => @document, 
      :locals => {:document => @document}, 
      :layout => '/layouts/toolbox'
    ).and_return('content')
    helper.frame_for(@document).should have_tag("div.frame.show.document.document_#{@document.id}") do
      with_tag('script.metadata[type=application/json]')
    end
  end

  it "should build a frame to edit a record" do
    helper.should_receive(:render).with(
      :partial => '/form',
      :object => @document,
      :locals => {:document => @document},
      :layout => '/layouts/toolbox'
    ).and_return('form')
    helper.frame_for(@document, 'form').should have_tag("div.frame.edit.document_#{@document.id}") do
      with_tag('script.metadata[type=application/json]')
    end
  end


  it "should build a frame to create a record (given new record)" do
    document = Factory.build(:document)
    helper.should_receive(:render).with(
      :partial => '/form',
      :object => document,
      :locals => {:document => document},
      :layout => '/layouts/toolbox'
    ).and_return('form')
    helper.frame_for(document, 'form', :title => 'New Document').should have_tag("div.frame.new.document.new_document") do
      with_tag('script.metadata[type=application/json]')
    end
  end

  it "should help to push a frame to toolbox to show a record" do
    helper.stub!(:frame_for).and_return('Frame Content')
    rjs_for.push_frame_for(@document).should == %Q[Toolbox.push("Frame Content");]
  end

  it "should help to update a frame for a record" do
    helper.stub!(:frame_content_for).and_return('Frame Content')
    rjs_for.update_frame_for(@document).should == %Q[Toolbox.frames(".show.document_#{@document.id}").html("Frame Content");]
    
  end


end

