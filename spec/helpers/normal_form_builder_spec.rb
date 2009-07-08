require File.dirname(__FILE__) + '/../spec_helper'

describe 'NormalFormBuilder' do
  before(:each) do
    @builder = NormalFormBuilder
  end
  it "should be a FormBuilder" do
    @builder.should < ActionView::Helpers::FormBuilder
  end
end

describe 'NormalFormBuilder', 'in a form with new Content' do
  before(:each) do
    ActionView::Base.send :include, ApplicationHelper
    ActionView::Base.send :include, InterfaceHelper # FIXME shouldn't Desert have done this already?
    @view = ActionView::Base.new
    @view.stub!(:url_for).and_return('/foo')
    @view.stub!(:protect_against_forgery?).and_return(false)
    @content = Factory.build :content
    @builder = NormalFormBuilder.new :content, Content.new, @view, {}, nil
  end

  describe "with a text_field" do
    before(:each) do
      @html = @builder.text_field(:title, :label => 'The slanky Title')
    end
    it "should render something" do
      @html.should_not be_empty
    end
    it "should have a DIV and the text input with a label" do
      @html.should have_tag('div.title') do
        with_tag('label', "The slanky Title")
        with_tag('input#content_title[name=?]', "content[title]")
      end
    end
  end

  describe "with a text_area" do
    before(:each) do
      @html = @builder.text_area(:body, :label => 'The skinny Body')
    end
    it "should have a DIV and the textarea with a label" do
      @html.should have_tag('div') do
        with_tag('label', "The skinny Body")
        with_tag('textarea#content_body[name=?]', "content[body]")
      end
    end
  end

  describe "with a select" do
    before(:each) do
      select_options = [["foo",1], ["bar", 2], ["baz", 3]]
      @html = @builder.select(:state, select_options, { :label => 'Select the type' })
    end
    it "should have a DIV and the select field with options and a label" do
      @html.should have_tag('div') do
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
      select_options = [["foo",1], ["bar", 2], ["baz", 3]]
      @html = @builder.collection_select(:state, select_options, :last, :first, { :label => 'Select the type' })
    end
    it "should have a DIV and the select field with options and a label" do
      @html.should have_tag('div') do
        with_tag('label', "Select the type")
        with_tag('select#content_state[name=?]', "content[state]") do
          with_tag('option[value=?]', 1, 'foo')
          with_tag('option[value=?]', 2, 'bar')
          with_tag('option[value=?]', 3, 'baz')
        end
      end
    end
  end
  describe "with a check_box" do
    before(:each) do
      @html = @builder.check_box(:title, :label => 'A Checkbox for a String??')
    end
    it "should render something" do
      @html.should_not be_empty
    end
    it "should have a DIV and the text input with a label" do
      @html.should have_tag('div') do
        with_tag('label', 'A Checkbox for a String??')
        with_tag('input#content_title[name=?]', "content[title]")
      end
    end
  end

  describe "with a select_picture" do
    before(:each) do
      @html = @builder.select_picture
    end
    it "should render something" do
      @html.should_not be_empty
    end
  end

end

