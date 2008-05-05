require File.dirname(__FILE__) + '/../spec_helper'

describe NormalFormBuilder do
  before(:each) do
    @builder = NormalFormBuilder
  end
  it "should be a FormBuilder" do
    @builder.should < ActionView::Helpers::FormBuilder
  end
end

describe NormalFormBuilder, 'in a form' do
  before(:each) do
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
  end

  describe "with a text_field" do
    before(:each) do
      @html = _erbout = ''
      @view.form_for(:content, Content.new, :url => '/foo', :builder => NormalFormBuilder) do |f|
          _erbout << f.text_field(:title, :label => 'The slanky Title')
      end
    end
    it "should render something" do
      @html.should_not be_empty
    end
    it "should have a paragraph and the text input with a label" do
      @html.should have_tag('p') do
        with_tag('label', "The slanky Title")
        with_tag('input#content_title[name=?]', "content[title]")
      end
    end
  end

  describe "with a text_area" do
    before(:each) do
      @html = _erbout = ''
      @view.form_for(:content, Content.new, :url => '/foo', :builder => NormalFormBuilder) do |f|
          _erbout << f.text_area(:body, :label => 'The skinny Body')
      end
    end
    it "should have a paragraph and the text input with a label" do
      @html.should have_tag('p') do
        with_tag('label', "The skinny Body")
        with_tag('textarea#content_body[name=?]', "content[body]")
      end
    end
  end
end

