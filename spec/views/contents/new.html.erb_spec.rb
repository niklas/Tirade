require File.dirname(__FILE__) + '/../../spec_helper'

describe "/contents/new.html.erb" do
  include ContentsHelper
  
  before(:each) do
    @content = mock_model(Content)
    @content.stub!(:new_record?).and_return(true)
    @content.stub!(:title).and_return("MyString")
    @content.stub!(:description).and_return("MyText")
    @content.stub!(:body).and_return("MyText")
    @content.stub!(:type).and_return("MyString")
    assigns[:content] = @content
  end

  it "should render new form" do
    render "/contents/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", contents_path) do
      with_tag("input#content_title[name=?]", "content[title]")
      with_tag("textarea#content_description[name=?]", "content[description]")
      with_tag("textarea#content_body[name=?]", "content[body]")
      with_tag("select#content_type[name=?]", "content[type]")
      without_tag("input#content_state[name=?]", "content[state]")
      without_tag("input#content_position[name=?]", "content[position]")
      without_tag("input#content_lft[name=?]", "content[lft]")
      without_tag("input#content_rgt[name=?]", "content[rgt]")
    end
  end
end


