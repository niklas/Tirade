require File.dirname(__FILE__) + '/../../spec_helper'

describe "/contents/edit.html.erb" do
  ActionView::Base.default_form_builder = NormalFormBuilder
  include ContentsHelper
  
  before do
    @content = mock_model(Content)
    @content.stub!(:title).and_return("MyString")
    @content.stub!(:description).and_return("MyText")
    @content.stub!(:markup?).and_return(false)
    @content.stub!(:acting_roles).and_return([])
    @content.stub!(:body).and_return("MyText")
    @content.stub!(:published_at).and_return(Time.now)
    @content.stub!(:new_record?).and_return(false)
    @content.stub!(:images).and_return([])
    @content.stub!(:class_name).and_return('Content')
    @content.stub!(:table_name).and_return('contents')
    @content.stub!(:wanted_parent_id).and_return(nil)
    @content.stub!(:acts_as?).and_return(false)
    # FIXME why does InterfaceHelper#current_model not recognize @content
    assigns[:model] = @content
    assigns[:content] = @content
  end


  it "should render edit form" do
    render "/model/edit.html.erb"
    
    response.should have_tag("form[action=#{content_path(@content)}][method=post]") do
      with_tag('input#content_title[name=?]', "content[title]")
      #with_tag('textarea#content_description[name=?]', "content[description]")
      #with_tag('textarea#content_body[name=?]', "content[body]")
      # TODO should Content have image_ids ? if yes, fix it!
      #with_tag('input[name=?]', "content[image_ids][]")
      without_tag('input#content_type[name=?]', "content[type]")
      without_tag('input#content_state[name=?]', "content[state]")
      without_tag('input#content_position[name=?]', "content[position]")
      without_tag('input#content_lft[name=?]', "content[lft]")
      without_tag('input#content_rgt[name=?]', "content[rgt]")
    end
  end
end


