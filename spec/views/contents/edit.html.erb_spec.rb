require File.dirname(__FILE__) + '/../../spec_helper'

describe "/contents/edit.html.erb" do
  ActionView::Base.class_eval do 
    self.default_form_builder = NormalFormBuilder
    include ContentsHelper
    include InterfaceHelper
  end
  
  before do
    @content = Factory(:content)
    assigns[:object] = @content
    assigns[:content] = @content
    template.stub!(:model_name).and_return('Content')
    template.stub!(:model).and_return(Content)
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


