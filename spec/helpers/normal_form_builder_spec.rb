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
    @view.stub!(:authorized?).and_return(true)
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

describe NormalFormBuilder, 'in a form with existing NOT scoping Rendering' do
  before(:each) do
    ActionView::Base.send :include, ApplicationHelper
    ActionView::Base.send :include, InterfaceHelper # FIXME shouldn't Desert have done this already?
    @view = ActionView::Base.new
    @view.view_paths.unshift 'app/views'
    @view.stub!(:url_for).and_return('/foo')
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:authorized?).and_return(true)
    @rendering = Factory :rendering, :assignment => 'fixed'
    @builder = NormalFormBuilder.new :rendering, @rendering, @view, {}, nil
  end

  it "should no scopings from Rendering" do
    @rendering.should have(:no).scopings
  end

  describe "defining scope" do
    before( :each ) do
      @html = @builder.define_scope
    end

    it "should render something" do
      @html.should_not be_blank
    end

    it "should render a set of fields as blueprint" do
      @html.should have_tag('div.scoping.blueprint') do
        with_tag('select.scope_attribute[name=?]', 'scope_attribute')
        with_tag('select.scope_comparison[name=?]', 'scope_comparison')
        with_tag('input.scope_value[type=text][name=?]', 'rendering[scope_definition][attribute_comparison]')
      end
    end


  end

end

describe NormalFormBuilder, 'in a form with existing scoping Rendering' do
  before(:each) do
    ActionView::Base.send :include, ApplicationHelper
    ActionView::Base.send :include, InterfaceHelper # FIXME shouldn't Desert have done this already?
    @view = ActionView::Base.new
    @view.view_paths.unshift 'app/views'
    @view.stub!(:url_for).and_return('/foo')
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:authorized?).and_return(true)
    @rendering = Factory :scoped_rendering, :scope_definition => { 
      :title => {:like => 'foo'}, 
      :id => {:greater_than => 23, :less_than_or_equal_to => 42},
      :order => 'ascend_by_title'
    }
    @builder = NormalFormBuilder.new :rendering, @rendering, @view, {}, nil
  end

  it "should get 3 scopings from Rendering" do
    @rendering.should have(3).scopings
  end

  describe "defining scope" do
    before( :each ) do
      @html = @builder.define_scope
    end

    it "should render something" do
      @html.should_not be_blank
    end

    it "should render a set of fields as blueprint (for the case the user removes all scopings)" do
      @html.should have_tag('div.scoping.blueprint') do
        with_tag('select.scope_attribute[name=?]', 'scope_attribute')
        with_tag('select.scope_comparison[name=?]', 'scope_comparison')
        with_tag('input.scope_value[type=text][name=?]', 'rendering[scope_definition][attribute_comparison]')
      end
    end

    it "should render a field to select ordering" do
      @html.should have_tag('div.order') do
        with_tag('select.order_attribute') do
          with_tag('option[selected][value=?]', 'title')
        end
        with_tag('select.order_direction') do
          with_tag('option[selected][value=?]', 'ascend')
          with_tag('option[value=?]', 'descend')
        end
      end
    end


    it "should render a set of fields for 'title_like'" do
      @html.should have_tag('div.scoping') do
        with_tag('select.scope_attribute[name=?]', 'scope_attribute') do
          with_tag('option[selected]', 'title')
        end
        with_tag('select.scope_comparison[name=?]', 'scope_comparison') do
          with_tag('optgroup[label=?]', 'title') do
            with_tag('option[selected]', 'like')
          end
        end
        with_tag('input.scope_value[type=text][name=?][value=?]', 'rendering[scope_definition][title_like]', 'foo')
      end
    end

    it "should render a set of fields for 'id_greater_than'" do
      @html.should have_tag('div.scoping') do
        with_tag('select.scope_attribute[name=?]', 'scope_attribute') do
          with_tag('option[selected]', 'id')
        end
        with_tag('select.scope_comparison[name=?]', 'scope_comparison') do
          with_tag('optgroup[label=?]', 'id') do
            with_tag('option[selected]', 'greater_than')
          end
        end
        with_tag('input.scope_value[type=text][name=?][value=?]', 'rendering[scope_definition][id_greater_than]',23)
      end
    end

    it "should render a set of fields for 'id_less_than_or_equal_to'" do
      @html.should have_tag('div.scoping') do
        with_tag('select.scope_attribute[name=?]', 'scope_attribute') do
          with_tag('option[selected]', 'id')
        end
        with_tag('select.scope_comparison[name=?]', 'scope_comparison') do
          with_tag('optgroup[label=?]', 'id') do
            with_tag('option[selected]', 'less_than_or_equal_to')
          end
        end
        with_tag('input.scope_value[type=text][name=?][value=?]', 'rendering[scope_definition][id_less_than_or_equal_to]', 42)
      end
    end
  end

end
