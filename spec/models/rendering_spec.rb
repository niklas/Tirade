require File.dirname(__FILE__) + '/../spec_helper'

describe Rendering, :type => :helper do
  before(:each) do
    @rendering = Rendering.new
  end

  it "should not be valid" do
    @rendering.should_not be_valid
  end

  describe ", setting a grid_id and page_id" do
    before(:each) do
      @rendering.grid_id = 5
      @rendering.page_id = 23
      @rendering.save
    end
    it "should be valid" do
      @rendering.should be_valid
    end

    describe ", setting another grid_id" do
      before do
        @rendering.grid_id = 42
      end
      it "should accept the new value" do
        @rendering.grid_id.should == 42
      end
      it "should remember that second change" do
        @rendering.should be_grid_id_changed
      end
      it "should remember the old value" do
        @rendering.grid_id_was.should == 5
      end
    end
  end

  it "should belong to a page" do
    Rendering.reflections[:page].should_not be_nil
    @rendering.should respond_to(:page)
  end
  it "should belong to a part" do
    Rendering.reflections[:part].should_not be_nil
    @rendering.should respond_to(:part)
  end
  it "should belong to a grid" do
    Rendering.reflections[:grid].should_not be_nil
    @rendering.should respond_to(:grid)
  end
  it "should belong to a content" do
    Rendering.reflections[:content].should_not be_nil
    @rendering.should respond_to(:content)
  end

  it "should know about its valid content types" do
    Rendering.valid_content_types.should_not be_empty
    Rendering.valid_content_types.should include(Document, Image, NewsFolder)
  end
end

describe Rendering, ' appended to the left column of the main page, containing a standard Content', :type => :helper do
  fixtures :all
  before(:each) do
    @page = pages(:main)
    @grid = grids(:layout_50_50_1)
    @goodbye = Factory(:document, :title => 'Goodbye', :description => 'If you read this, the page has come to an end' )
    lambda do
      @rendering = Rendering.create!(
        :page => @page,
        :grid => @grid,
        :content => @goodbye,
        :part => simple_preview
      )
    end.should change(Rendering,:count).by(1)
  end
  it "should have a Content" do
    @rendering.should be_has_content
  end
  it "should have a speaking label" do
    @rendering.label.should == 'Simple Preview: Goodbye'
  end
  it "should be the last item in the left column" do
    @page.renderings.for_grid(@grid).last.should == @rendering
  end
  #it "should set the content_type correctly" do
  #  @rendering.content_type.should == 'Document'
  #end
  it "should find the content" do
    lambda do
      found_content = @page.renderings.for_grid(@grid).last.content
      found_content.should == @goodbye
    end.should_not raise_error
  end

  describe ", rendering to html" do
    before(:each) do
      @html = @rendering.render
    end
    it "should render proper html" do
      @html.should have_tag('div.rendering.simple_preview.document') do
        with_tag('p',/If you read this, the page has come to an end/)
      end
    end
  end
end

describe Rendering, ' appended to the left column of the main page, containing a Document', :type => :helper do
  fixtures :all
  before(:each) do
    @page = pages(:main)
    @grid = grids(:layout_50_50_1)
    @love_letter = Factory(:document, :title => 'Love', :description => 'Hello Bla')
    @create_rendering = Proc.new {
      @rendering = Rendering.create!(
        :page => @page,
        :grid => @grid,
        :content => @love_letter,
        :part => simple_preview
      )
    }
  end
  it "should create a rendering" do
    @create_rendering.should change(Rendering,:count).by(1)
  end
  it "should be the last item in the left column" do
    @create_rendering.call
    @page.renderings.for_grid(@grid).last.should == @rendering
  end
  it "should set the content_type correctly" do
    @create_rendering.call
    #@rendering.content_type.should == 'Document'
    @rendering.content_type.should == 'Content' # STI with polymorphism fails
  end
  it "should find the content" do
    @create_rendering.call
    lambda do
      found_content = @page.renderings.for_grid(@grid).last.content
      found_content.should be_instance_of(Document)
      found_content.should == @love_letter
    end.should_not raise_error
  end

  describe ", rendering to html" do
    before(:each) do
      @create_rendering.call
      @html = @rendering.render
    end
    it "should render proper html" do
      @html.should have_tag('div.rendering.simple_preview.document') do
        with_tag('p',/Hello Bla/)
      end
    end
  end
end

describe Rendering, ' appended to the left column of the main page, containing an Image', :type => :helper do
  fixtures :all
  before(:each) do
    @page = pages(:main)
    @grid = grids(:layout_50_50_1)
    @content = images(:landscape)
    lambda do
      @rendering = Rendering.create!(
        :page => @page,
        :grid => @grid,
        :content => @content,
        :assignment => 'fixed',
        :part => parts(:image_preview)
      )
    end.should change(Rendering,:count).by(1)
  end
  it "should be the last item in the left column" do
    @page.renderings.for_grid(@grid).last.should == @rendering
  end
  it "should have the correct content_type set" do
    @rendering.content_type.should == 'Image'
  end
  it "should find the content" do
    lambda do
      @found_content = @page.renderings.for_grid(@grid).last.content
    end.should_not raise_error
    @found_content.should be_instance_of(Image)
    @found_content.should == @content
  end

end

describe "The Renderings loaded by fixtures" do
  fixtures :all
  describe "main1" do
    before(:each) do
      @r = renderings(:main1)
    end
    it do
      @r.grid.should_not be_nil
    end
  end
  describe "main11" do
    before(:each) do
      @r = renderings(:main11)
    end
    it "its grid" do
      @r.grid.should_not be_nil
    end
    it "its content" do
      @r.content.should_not be_nil
    end
    it "its part" do
      @r.part.should_not be_nil
    end
    it "its page" do
      @r.page.should_not be_nil
    end
  end
  describe "main12" do
    before(:each) do
      @r = renderings(:main12)
    end
    it "its grid" do
      @r.grid.should_not be_nil
    end
    it "its content" do
      @r.content.should_not be_nil
    end
    it "its part" do
      @r.part.should_not be_nil
    end
    it "its page" do
      @r.page.should_not be_nil
    end
  end
  describe "the clone of main12" do
    before(:each) do
      @o = renderings(:main12)
      @r = @o.clone
    end
    it "should have the same grid" do
      @r.grid.should_not be_nil
      @r.grid.should == @o.grid
    end
    it "should have the same content" do
      @r.content.should_not be_nil
      @r.content.should == @o.content
    end
    it "should have the same part" do
      @r.part.should_not be_nil
      @r.part.should == @o.part
    end
    it "should have the same page" do
      @r.page.should_not be_nil
      @r.page.should == @o.page
    end
    it "should be valid" do
      @r.should be_valid
    end
  end

end

describe Rendering, "with Page with trailing path" do
  before( :each ) do
    @rendering = Factory(:rendering)
    @page = @rendering.page
    @trailing_path = ["Goodbye", "Morning", "Glory"]
    @rendering.page.trailing_path = @trailing_path
  end

  it "should keep the same page" do
    @rendering.page.should == @page
  end

  it "should access this path" do
    @rendering.trailing_path_of_page.should== @trailing_path
  end

  it "should include this path in its final options" do
    @rendering.final_options.should have_key('trailing_path_of_page')
    @rendering.final_options['trailing_path_of_page'].should == @trailing_path
  end
end

describe "renderable Rendering", :shared => true do
  before( :each ) do
    @trailing_path = ['Goodbye']
    @rendering.stub!(:trailing_path_of_page).and_return(@trailing_path)
  end
  def do_render
    @html = @rendering.render
  end

  it "should be successful" do
    lambda { do_render }.should_not raise_error
    @html.should_not be_blank
  end
  
  it "should give the (remaining) :trailing_path_of_page into the part" do
    @rendering.final_options.should have_key('trailing_path_of_page')
    @rendering.final_options['trailing_path_of_page'].should == @trailing_path
  end
end

describe "A Rendering", "with a fixed assigned Document" do
  before( :each ) do
    @content = Factory(:document)
    @rendering = Factory(:rendering, :assignment => 'fixed', :content => @content)
  end
  it "should find fixed content (polymorphic)" do
    @rendering.content.should_not be_nil
    @rendering.content.should == @content
    @rendering.content_type.should == 'Content' # STI parent
    @rendering.content_id.should == @content.id
  end
  it "should have assignment: :fixed" do
    @rendering.assignment.should == 'fixed'
  end
  it_should_behave_like 'renderable Rendering'
end

describe "A Rendering", "with a fixed assigned Image" do
  before( :each ) do
    @content = Factory(:image)
    @rendering = Factory(:rendering, :assignment => 'fixed', :content => @content)
  end
  it "should find fixed content (polymorphic)" do
    @rendering.content.should_not be_nil
    @rendering.content.should == @content
    @rendering.content_type.should == 'Image'
    @rendering.content_id.should == @content.id
  end
  it "should have assignment: :fixed" do
    @rendering.assignment.should == 'fixed'
  end
  it_should_behave_like 'renderable Rendering'
end

describe "A Rendering", "with an assignment by_title_from_trailing_url " do
  before(:each) do
    @rendering = Factory :rendering, :assignment => 'by_title_from_trailing_url'
    @rendering.stub!(:trailing_path_of_page).and_return('goodbye')
  end
  it "should be valid" do
    @rendering.should be_valid
  end
  it "should assignmend by_title_from_trailing_url" do
    @rendering.assignment.should == 'by_title_from_trailing_url'
  end
  it "should look for Documents" do
    @rendering.content_type.should == 'Document'
  end
  it "should find Content#find_by_slug(trailing_path_of_page.urlize)" do
    content = "jojojo"
    Document.should_receive(:find_by_slug).with('goodbye').and_return( content )
    @rendering.content.should == content
  end
  it_should_behave_like 'renderable Rendering'
end


describe "Rendering with collection of Documents", :shared => true do
  it "should be valid" do
    @rendering.should be_valid
  end
  it "should return a collection of Documents" do
    @rendering.content.should respond_to(:each)
    @rendering.content.first.should be_a(Document)
  end
  it_should_behave_like 'renderable Rendering'
end



describe Rendering, "scoped for multiple Documents" do
  before( :each ) do
    @rendering = Factory.build(:scoped_rendering)
  end
  it_should_behave_like 'Rendering with collection of Documents'
end




describe Rendering, "scoped for multiple Documents with order" do
  before( :each ) do
    @rendering = Factory.build(:scoped_rendering, :scope_definition => {:order => 'ascending_by_title'})
  end
  it_should_behave_like 'Rendering with collection of Documents'

  it "should have set the order in the conditions" do
    @rendering.scope.order.should == 'ascending_by_title'
  end
end

describe Rendering, "scoped by params" do
  def self.it_should_create_scope_from_params(scope, prms={})
    describe "with #{prms.inspect}" do
      before( :each ) do
        @rendering = Factory.build :scoped_rendering, :scope_definition => prms
      end

      it "should use conditions #{scope.conditions.inspect}" do
        @rendering.scope.conditions.should == scope.conditions
      end

      it "should have content_class of Document" do
        @rendering.content_class.should == Document
      end

      it "should succeed searching" do
        lambda { @rendering.scope.all }.should_not raise_error
      end

      it "should provide scopings (for form)" do
        lambda { @scopings = @rendering.scopings }.should_not raise_error
        @scopings.should be_an(Array)
        @scopings.should_not be_empty
        @scopings.each do |scoping|
          scoping.should be_a(Rendering::Scoping)
          scoping.attribute.should be_a String
          scoping.comparison.should be_a String
          scoping.value.should_not be_blank
          name = scoping.name
          name.should_not be_blank
          name.should == "#{scoping.attribute}_#{scoping.comparison}"
          scoping.send(name).should == scoping.value
        end
      end
    end
  end

  it_should_create_scope_from_params Document.search(:order => 'ascend_by_title'), :order_attribute => 'title', :order_direction => 'ascend'
  it_should_create_scope_from_params Document.search(:order => 'descend_by_title'), :order_attribute => 'title', :order_direction => 'descend'
  it_should_create_scope_from_params Document.search(:order => 'ascend_by_title'), :order_attribute => 'title'

  context 'order like named scope' do
    it_should_create_scope_from_params Document.search(:order => 'ascend_by_title'), :order => 'ascend_by_title'
  end

  it_should_create_scope_from_params Document.search(:title_like => 'foo'), 
     :title => { :like => 'foo' }

  it_should_create_scope_from_params Document.search(:order => 'ascend_by_title', :title_like => 'foo'), 
    :order_attribute => 'title', :title => { :like => 'foo' }

  it_should_create_scope_from_params Document.search(:order => 'ascend_by_title', :title_like => 'foo', :id_lt => 23), 
    :order_attribute => 'title', :title => { :like => 'foo' }, :id_lt => 23

  it_should_create_scope_from_params Document.search(:order => 'ascend_by_title', :title_like => 'foo', :id_gt => 23, :id_lte => 42), 
    :order_attribute => 'title', :title => { :like => 'foo' }, :id => {:gt => 23, :lte => 42}
end

describe Rendering, "without content", :type => :helper do
  before( :each ) do
    @rendering = Factory(:rendering, :content => nil)
  end

  it "should really have no content" do
    @rendering.content.should be_nil
  end

  it "should accept drop of all content types of the part" do
    @rendering.part.supported_types.each do |ctype|
      @rendering.drop_acceptions.should include(ctype)
    end
  end

  describe "rendering it" do
    def do_render
      @html = @rendering.render
    end

    it "should be sucessful" do
      lambda { do_render }.should_not raise_error
    end

    it "should render with a warning about not having any content" do
      do_render
      @html.should_not be_blank
      @html.should have_text(/This Rendering has no Content/)
    end

  end

end

describe Rendering, "without Part" do
  before( :each ) do
    @rendering = Factory :rendering, :part => nil, :content => Factory(:document)
  end
  it "should accept only drop of part" do
    @rendering.drop_acceptions.should == %w(Part)
  end
end

describe "without a Part or any Content" do
  before( :each ) do
    @rendering = Factory :rendering, :part => nil, :content_type => nil
  end
  it "should accept drop of part" do
    @rendering.drop_acceptions.should include('Part')
  end
  it "should accept drop of all registered content types" do
    Tirade::ActiveRecord::Content.classes.each do |ctype|
      @rendering.drop_acceptions.should include(ctype.to_s)
    end
  end
end

describe Rendering, "with extra CSS classes" do
  describe "valid Rendering", :shared => true do
    it "should be valid" do
      @rendering.should be_valid
    end
    it "should provide CSS classes as Array" do
      @rendering.css_classes.should be_a(Array)
    end
    it "should not contain empty CSS classes" do
      @rendering.css_classes.should_not include('')
    end
  end
  describe "extra big Rendering", :shared => true do
    it "should be extra" do
      @rendering.css_classes.should include('extra')
    end
    it "should be big" do
      @rendering.css_classes.should include('big')
    end
  end
  describe "with one class" do
    before( :each ) do
      @rendering = Factory.build :rendering, :css_classes_list => 'big'
    end
    it_should_behave_like 'valid Rendering'
    it "should be big" do
      @rendering.css_classes.should include('big')
    end
  end
  describe "with spaces" do
    before( :each ) do
      @rendering = Factory.build :rendering, :css_classes_list => 'extra big'
    end
    it_should_behave_like 'valid Rendering'
    it_should_behave_like 'extra big Rendering'
  end
  describe "with commas" do
    before( :each ) do
      @rendering = Factory.build :rendering, :css_classes_list => 'extra,big'
    end
    it_should_behave_like 'valid Rendering'
    it_should_behave_like 'extra big Rendering'
  end
  describe "with commas and spaces" do
    before( :each ) do
      @rendering = Factory.build :rendering, :css_classes_list => 'extra, big'
    end
    it_should_behave_like 'valid Rendering'
    it_should_behave_like 'extra big Rendering'
  end
  describe "with bad characters in it" do
    before( :each ) do
      @rendering = Factory.build :rendering, :css_classes_list => '%extra, &big'
    end
    it "should not be valid" do
      @rendering.should_not be_valid
      @rendering.should have_at_least(1).errors_on(:css_classes)
    end
  end

  describe "empty" do
    before( :each ) do
      @rendering = Factory.build :rendering, :css_classes_list => nil
    end
    it "should ne empty" do
      @rendering.css_classes.should be_empty
    end
    it_should_behave_like 'valid Rendering'
  end
end
