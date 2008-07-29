require File.dirname(__FILE__) + '/../../spec_helper'

describe "/contents/edit.html.erb" do
  include ContentsHelper
  
  before do
    @content = mock_model(Content)
    @content.stub!(:title).and_return("MyString")
    @content.stub!(:description).and_return("MyText")
    @content.stub!(:body).and_return("MyText")
    @content.stub!(:published_at).and_return(Time.now)
    @content.stub!(:images).and_return([])
    assigns[:content] = @content
  end

  it "should render edit form" do
    render "/contents/edit.html.erb"
    
    response.should have_tag("form[action=#{content_path(@content)}][method=post]") do
      with_tag('input#content_title[name=?]', "content[title]")
      #with_tag('textarea#content_description[name=?]', "content[description]")
      #with_tag('textarea#content_body[name=?]', "content[body]")
      with_tag('input[name=?]', "content[image_ids][]")
      without_tag('input#content_type[name=?]', "content[type]")
      without_tag('input#content_state[name=?]', "content[state]")
      without_tag('input#content_position[name=?]', "content[position]")
      without_tag('input#content_lft[name=?]', "content[lft]")
      without_tag('input#content_rgt[name=?]', "content[rgt]")
    end
  end
end


