require File.dirname(__FILE__) + '/../../spec_helper'

describe "/renderings/edit.html.erb" do
  include RenderingsHelper
  ActionView::Base.class_eval do
    self.default_form_builder = ToolboxFormBuilder
    include InterfaceHelper
  end
  
  before do
    login_with_group :admin_renderings
    login_standard
  end

  describe "every form", :shared => true do
    it "should be success" do
      response.should be_success
    end
    it "should render edit form with scope blueprint" do
      response.should have_tag("form[action=#{rendering_path(@rendering)}][method=post]") do
        with_tag('select#rendering_assignment[name=?]', 'rendering[assignment]')
        with_tag('di.define_scope dd') do
          with_tag('div.scoping.blueprint') do
            with_tag('select.scope_attribute') do
              with_tag('option')
            end
            with_tag('select.scope_comparison') do
              with_tag('option')
            end
            with_tag('input.scope_value[type=text][name=?]', 'rendering[scope_definition][attribute_comparison]')
          end
        end
      end
    end
  end


  describe "with a Rendering without scope" do
    before( :each ) do
      @rendering = Factory(:rendering)
      assigns[:rendering] = @rendering
      render "/renderings/edit.html.erb"
    end
    it_should_behave_like 'every form'
  end

  describe "with a scoped Rendering" do
    before( :each ) do
      @rendering = Factory :scoped_rendering, :scope_definition => {:order => 'ascend_by_title', :title => {:like => 'fnord'} }
      assigns[:rendering] = @rendering
      render "/renderings/edit.html.erb"
    end
    it_should_behave_like 'every form'
    it "should render form elements for all scopes" do
      response.should have_tag('form di.define_scope dd') do
        with_tag('div.scoping') do
          with_tag('input.scope_value[name=?][value=?]', 'rendering[scope_definition][title_like]', 'fnord')
        end
      end
    end
    
  end

end


