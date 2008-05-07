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
    it "should have a paragraph and the textarea with a label" do
      @html.should have_tag('p') do
        with_tag('label', "The skinny Body")
        with_tag('textarea#content_body[name=?]', "content[body]")
      end
    end
  end

  describe "with a select" do
    before(:each) do
      @html = _erbout = ''
      select_options = {:foo => 1, :bar => 2, :baz => 3}
      @view.form_for(:content, Content.new, :url => '/foo', :builder => NormalFormBuilder) do |f|
          _erbout << f.select(:state, select_options, { :label => 'Select the type' })
      end
    end
    it "should have a paragraph and the select field with options and a label" do
      @html.should have_tag('p') do
        with_tag('label', "Select the type")
        with_tag('select#content_state[name=?]', "content[state]") do
          with_tag('option[value=?]', 1, 'foo')
          with_tag('option[value=?]', 2, 'bar')
          with_tag('option[value=?]', 3, 'baz')
        end
      end
    end
  end

  describe "with a collection_select" do
    before(:each) do
      @html = _erbout = ''
      select_options = [["foo",1], ["bar", 2], ["baz", 3]]
      @view.form_for(:content, Content.new, :url => '/foo', :builder => NormalFormBuilder) do |f|
          _erbout << f.collection_select(:state, select_options, :last, :first, { :label => 'Select the type' })
      end
    end
    it "should have a paragraph and the select field with options and a label" do
      @html.should have_tag('p') do
        with_tag('label', "Select the type")
        with_tag('select#content_state[name=?]', "content[state]") do
          with_tag('option[value=?]', 1, 'foo')
          with_tag('option[value=?]', 2, 'bar')
          with_tag('option[value=?]', 3, 'baz')
        end
      end
    end
  end
  describe "with a check_nox" do
    before(:each) do
      @html = _erbout = ''
      @view.form_for(:content, Content.new, :url => '/foo', :builder => NormalFormBuilder) do |f|
          _erbout << f.check_box(:title, :label => 'A Checkbox for a String??')
      end
    end
    it "should render something" do
      @html.should_not be_empty
    end
    it "should have a paragraph and the text input with a label" do
      @html.should have_tag('p') do
        with_tag('label', 'A Checkbox for a String??')
        with_tag('input#content_title[name=?]', "content[title]")
      end
    end
  end

end

