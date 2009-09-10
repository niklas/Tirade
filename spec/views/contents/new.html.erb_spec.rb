require File.dirname(__FILE__) + '/../../spec_helper'

describe "/contents/new.html.erb" do
  ActionView::Base.class_eval do
    include InterfaceHelper
    self.default_form_builder = NormalFormBuilder
  end
  include ContentsHelper
  
  describe "for a NewsItem" do
    before(:each) do
      @content = Factory.build(:news_item)
      assigns[:content] = @content
    end

    it "should render new form" do
      render "/contents/new.html.erb"

      response.should have_tag("form[action=?][method=post]", '/en/manage/news_items') do
        without_tag('p.default.warning')
        without_tag("input#news_item_state[name=?]", "news_item[state]")
        without_tag("input#news_item_position[name=?]", "news_item[position]")
        without_tag("input#news_item_lft[name=?]", "news_item[lft]")
        without_tag("input#news_item_rgt[name=?]", "news_item[rgt]")
        without_tag("textarea#news_item_body", "news_item[body]")
        with_tag("input#news_item_title[name=?]", "news_item[title]")
        #with_tag('p') do
        #  with_tag('label', 'Description')
        #  with_tag("textarea#news_item_description[name=?]", "news_item[description]")
        #end
        with_tag("textarea#news_item_body[name=?]", "news_item[body]")
        #with_tag('p.type') do
        #  with_tag('label', 'Type')
        #  with_tag("select#news_item_type[name=?]", "news_item[type]")
        #end
        with_tag("select#news_item_parent_id[name=?]", "news_item[parent_id]")
      end
    end
  end

  describe "for a Document" do
    before(:each) do
      @content = Factory.build(:document)
      assigns[:content] = @content
    end

    it "should render new form" do
      render "/contents/new.html.erb"
      
      response.should have_tag("form[action=?][method=post]", documents_path) do
        without_tag('p.default.warning')
        without_tag("input#document_state[name=?]", "document[state]")
        without_tag("input#document_position[name=?]", "document[position]")
        without_tag("input#document_lft[name=?]", "document[lft]")
        without_tag("input#document_rgt[name=?]", "document[rgt]")
        with_tag("input#document_title[name=?]", "document[title]")
        with_tag("textarea#document_description[name=?]", "document[description]")
        with_tag("textarea#document_body[name=?]", "document[body]")
        #with_tag('div.type') do
        #  with_tag('label', 'Type')
        #  with_tag("select#document_type[name=?]", "document[type]")
        #end
        with_tag("select#document_parent_id[name=?]", "document[parent_id]")
      end
    end
  end

end


