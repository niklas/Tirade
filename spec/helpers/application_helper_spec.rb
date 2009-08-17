require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  fixtures :all
  before( :each ) do
    helper_authorizes_all
  end

  describe "public_content_link" do

    it "should build link to main page" do
      helper.public_content_link(pages(:main)).should have_tag('a[href=?]','/en/')
    end
    
    it "should build link to welcome page" do
      helper.public_content_link(pages(:welcome)).should have_tag('a[href=?]','/en/welcome')
    end

    it "should build link to welcome page with :item_id" do
      helper.public_content_link(pages(:welcome), :item_id => 23).should have_tag('a[href=?]','/en/welcome/23')
    end
    
    it "should build link to 'welcome' (string)" do
      helper.public_content_link('welcome', :item_id => 23).should have_tag('a[href=?]','/en/welcome/23')
    end
    it "should build link to 'welcome' (string) with :item_id" do
      helper.public_content_link('welcome', :item_id => 23).should have_tag('a[href=?]','/en/welcome/23')
    end
    
  end

  describe "link_to_show(Document)" do
    
    before( :each ) do
      @record = Factory(:document)
    end
    it "should build a link to show a Document" do
      helper.link_to_show(@record).should have_tag('a.show.document[href=?]', document_path(@record))
    end

    it "should build a link to show a Document with extra params" do
      helper.link_to_show(@record, :params => {:locale => 'de'}).should have_tag('a.show.document[href=?]', document_path(@record, :locale => 'de'))
    end

    it "should build a link to show a Document with extra html options" do
      helper.link_to_show(@record, :class => 'extra').should have_tag('a.show.extra.document[href=?]', document_path(@record))
    end
    
    it "should build a link to show a Document with extra params and html options" do
      helper.link_to_show(@record, :class => 'extra', :params => { :locale => 'de' } ).should have_tag('a.show.extra.document[href=?]', document_path(@record, :locale => 'de'))
    end

  end

  describe "link_to_edit(Document)" do

    before( :each ) do
      @record = Factory(:document)
    end

    it "should build a link to edit a Document" do
      helper.link_to_edit(@record).should have_tag('a.edit.document[href=?]', edit_document_path(@record))
    end

    it "should build a link to edit a Document with extra params" do
      helper.link_to_edit(@record, :params => {:locale => 'de'}).should have_tag('a.edit.document[href=?]', edit_document_path(@record, :locale => 'de'))
    end

    it "should build a link to edit a Document with extra html options" do
      helper.link_to_edit(@record, :class => 'extra').should have_tag('a.edit.extra.document[href=?]', edit_document_path(@record))
    end
    
    it "should build a link to edit a Document with extra params and html options" do
      helper.link_to_edit(@record, :class => 'extra', :params => { :locale => 'de' } ).should have_tag('a.edit.extra.document[href=?]', edit_document_path(@record, :locale => 'de'))
    end
  end

  describe "link_to_edit(NewsItem)" do

    before( :each ) do
      @record = Factory(:news_item)
    end

    it "should build a link to edit a Document" do
      helper.link_to_edit(@record).should have_tag('a.edit.news_item[href=?]', edit_news_item_path(@record))
    end
    
  end

end
