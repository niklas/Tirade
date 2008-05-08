require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  fixtures :all

  it "should build link to main page" do
    public_content_link(pages(:main)).should have_tag('a[href=?]','/')
  end
  
  it "should build link to welcome page" do
    public_content_link(pages(:welcome)).should have_tag('a[href=?]','/welcome')
  end

  it "should build link to welcome page with :item_id" do
    public_content_link(pages(:welcome), :item_id => 23).should have_tag('a[href=?]','/welcome/23')
  end
  
  it "should build link to 'welcome' (string)" do
    public_content_link('welcome', :item_id => 23).should have_tag('a[href=?]','/welcome/23')
  end
  it "should build link to 'welcome' (string) with :item_id" do
    public_content_link('welcome', :item_id => 23).should have_tag('a[href=?]','/welcome/23')
  end
end
