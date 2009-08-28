require File.dirname(__FILE__) + '/../../spec_helper'

describe "/rendering/_rendering.html.haml" do
  fixtures :pages, :grids, :renderings, :contents
  include RenderHelper
  before( :each ) do
    login_standard
    login_with_groups :admin_renderings
    template.view_paths.unshift 'app/views'
  end

  def html
    template.render_rendering @rendering
  end

  def have_rendering(select='',*args)
    select = ".#{select}" if select =~ /^\w/
    have_tag("div.rendering#{select}", *args)
  end

  def have_warning(about='',*args)
    about = ".#{about}" if about =~ /^\w/
    have_tag("div.warning#{about}", *args)
  end

  def with_update_link(set, *args)
    with_tag("a.update.rendering[onclick*=#{set}]", *args)
  end


  it "should be renderable with factory settings" do
    @rendering = Factory :rendering
    lambda { @html = html }.should_not raise_error
    @html.should_not be_empty
  end

  context "for a Rendering" do

    describe "layout component", :shared => true do
      it "should render a div.rendering" do
        html.should have_rendering
      end
    end

    describe "finished component", :shared => true do
      it_should_behave_like 'layout component'
      it "should not have warning about missing Content" do
        html.should_not have_warning('without_content')
      end
      it "should not have warning about missing Part" do
        html.should_not have_warning('without_part')
      end
      it "should have at least one tag in it" do
        html.should have_rendering(' > *')
      end
    end

    describe "missing a Part", :shared => true do
      it_should_behave_like 'layout component'
      it "should show a warning about missing Part" do
        html.should have_warning('without_part')
      end
    end

    describe "missing a Content", :shared => true do
      it_should_behave_like 'layout component'
      it "should show a warning about missing Content" do
        html.should have_warning('without_content')
      end
    end

    ###########

    describe "without a Part" do
      before( :each ) do
        @rendering = Factory :rendering, :part => nil
      end
      it_should_behave_like 'missing a Part'
    end

    describe "with assignment 'none' without a Content" do
      before( :each ) do
        @rendering = Factory :rendering, :assignment => 'none'
      end
      it_should_behave_like 'finished component'
    end

    describe "with assignment 'fixed' without a Content and #content_type" do
      before( :each ) do
        @rendering = Factory :rendering, :assignment => 'fixed', :content_type => nil
      end
      it_should_behave_like 'missing a Content'
      it "should have a part with supported Content types" do
        @rendering.part.supported_types.should_not be_empty
      end
      it "should present a list of all supported Content types of the Part to select" do
        html.should have_tag('ul.list') do
          @rendering.part.supported_types.each do |ctype|
            with_update_link("content_type: '#{ctype}'")
          end
        end
      end
    end

    describe "with assignment 'fixed' without a Content but with #content_type" do
      before( :each ) do
        @rendering = Factory :rendering, :assignment => 'fixed', :content_type => 'Document'
      end
      it_should_behave_like 'missing a Content'
      it "should show link to index of set #content_type" do
        html.should have_tag('a.index.documents')
      end
    end

    describe "without a Part or any Content" do
      before( :each ) do
        @rendering = Factory :rendering, :part => nil, :content_type => nil
      end
      it_should_behave_like 'missing a Content'
      it_should_behave_like 'missing a Part'
      it "should present a list of all supported Content Types to select" do
        html.should have_tag('ul.list') do
          Tirade::ActiveRecord::Content.classes.each do |ctype|
            with_update_link("content_type: '#{ctype}'")
          end
        end
      end
    end

    describe "without a Part but with a 'fixed' Content" do
      before( :each ) do
        @rendering = Factory :rendering, :part => nil, :content => Factory(:document)
      end

      it "should get a rendering which has content" do
        @rendering.should have_content
      end

      it_should_behave_like 'missing a Part'
      it "should present a list of all Parts matching its content" do
        html.should have_tag('ul.list') do
          with_update_link('part_id')
        end
      end
      
    end

    describe "with a static Part and no Content" do
      before( :each ) do
        @rendering = Factory :rendering, :part => Factory(:static_part), :content => nil
      end

      it_should_behave_like 'finished component'
    end

  end


  # Rendering ohne Part #  => warning.without_part
  # Rendering ohne Content
  #   Part braucht keinen Content => render ohne Content
  #   Part braucht Content
  #      hat content_type
  #         nein: => select content type [Drop any content]
  #         ja: => link to document list [Drop exactly this Content]
  #
end
