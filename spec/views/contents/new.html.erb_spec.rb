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
    @content.stub!(:state).and_return("MyString")
    @content.stub!(:owner_id).and_return("1")
    @content.stub!(:published_at).and_return(Time.now)
    @content.stub!(:position).and_return("1")
    @content.stub!(:parent_id).and_return("1")
    @content.stub!(:lft).and_return("1")
    @content.stub!(:rgt).and_return("1")
    assigns[:content] = @content
  end

  it "should render new form" do
    render "/contents/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", contents_path) do
      with_tag("input#content_title[name=?]", "content[title]")
      with_tag("textarea#content_description[name=?]", "content[description]")
      with_tag("textarea#content_body[name=?]", "content[body]")
      with_tag("input#content_type[name=?]", "content[type]")
      with_tag("input#content_state[name=?]", "content[state]")
      with_tag("input#content_position[name=?]", "content[position]")
      with_tag("input#content_lft[name=?]", "content[lft]")
      with_tag("input#content_rgt[name=?]", "content[rgt]")
    end
  end
end


