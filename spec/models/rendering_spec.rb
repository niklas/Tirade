require File.dirname(__FILE__) + '/../spec_helper'

describe Rendering do
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

describe Rendering, ' appended to the left column of the main page, containing a standard Content' do
  fixtures :all
  before(:each) do
    @page = pages(:main)
    @grid = grids(:layout_50_50_1)
    @goodbye = contents(:goodbye)
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
    @rendering.label.should == 'Simple Preview with Goodbye'
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
        with_tag('h2','Goodbye')
        with_tag('p',/If you read this, the page has come to an end/)
      end
    end
  end
end

describe Rendering, ' appended to the left column of the main page, containing a Document' do
  fixtures :all
  before(:each) do
    @page = pages(:main)
    @grid = grids(:layout_50_50_1)
    @love_letter = contents(:love_letter)
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
        with_tag('h2','Love Letter')
        with_tag('p',/Hello Bla/)
      end
    end
  end
end

describe Rendering, ' appended to the left column of the main page, containing an Image' do
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
      found_content = @page.renderings.for_grid(@grid).last.content
      found_content.should be_instance_of(Image)
      found_content.should == @content
    end.should_not raise_error
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

describe "A Rendering", "with an assigned Content" do
  it "should find fixed content (polymorphic)"
  it "should be able to render a Part for single Content"
  it "should give the (remaining) :trailing_path_of_page into the part ?"
  it "should have assignment: :fixed"
end

describe "A Rendering", "with an assignment by_title_from_trailing_url " do
  fixtures :all
  before(:each) do
    @page = pages(:portal)
    @rendering = Rendering.new(
      :page => @page,
      :grid => @page.grids.first,
      :content_type => 'Content',
      :assignment => 'by_title_from_trailing_url',
      :part => simple_preview
    )
    @rendering.stub!(:trailing_path_of_page).and_return(['Goodbye'])
  end
  it "should find Content#find_by_slug(trailing_path_of_page.urlize)" do
    Content.should_receive(:find_by_slug).with('goodbye').and_return( contents(:love_letter) )
    @rendering.content.should_not be_nil
  end
  it "should be able to render a Part for single Content"
  it "should give the (remaining) :trailing_path_of_page into the part ?"
end

describe "A Rendering", "with a scoped assignment for Document" do
  fixtures :all
  before(:each) do
    @page = pages(:main)
    @scope = {
      :order => 'title',
      :skip => 3,
      :limit => 5
    }.with_indifferent_access
    @rendering = Rendering.new(
      :page => @page,
      :grid => @page.grids.first,
      :content_type => 'Document',
      :assignment => 'scope',
      :scope => @scope,
      :part => simple_preview
    )
  end
  it "should be valid" do
    @rendering.should be_valid
  end
  it "should accept the scope hash" do
    @rendering.scope.should == @scope
  end
  it "should find the Documents with the specified scope" do
    contents = @rendering.content
    contents.should_not be_empty
    contents.should == Document.find(:all, :order => 'title', :offset => 3, :limit => 5)
  end
end


describe "A Rendering", "with a scoped assignment for Document, but empty scope hash" do
  fixtures :all
  before(:each) do
    @page = pages(:main)
    @rendering = Rendering.new(
      :page => @page,
      :grid => @page.grids.first,
      :content_type => 'Document',
      :assignment => 'scope',
      :scope => {}.with_indifferent_access,
      :part => simple_preview
    )
  end
  it "should be valid" do
    @rendering.should be_valid
  end
  it "should accept the empty scope hash" do
    @rendering.scope.should == {}
  end
  it "should find all Documents" do
    contents = @rendering.content
    contents.should_not be_empty
    contents.should == Document.all
  end
end
