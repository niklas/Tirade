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
        :part => parts(:simple_preview)
      )
    end.should change(Rendering,:count).by(1)
  end
  it "should be the last item in the left column" do
    @page.renderings.for_grid(@grid).last.should == @rendering
  end
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
    lambda do
      @rendering = Rendering.create!(
        :page => @page,
        :grid => @grid,
        :content => @love_letter,
        :part => parts(:simple_preview)
      )
    end.should change(Rendering,:count).by(1)
  end
  it "should be the last item in the left column" do
    @page.renderings.for_grid(@grid).last.should == @rendering
  end
  it "should find the content" do
    lambda do
      found_content = @page.renderings.for_grid(@grid).last.content
      found_content.should be_instance_of(Document)
      found_content.should == @love_letter
    end.should_not raise_error
  end

  describe ", rendering to html" do
    before(:each) do
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
        :part => parts(:simple_preview)
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

  describe ", rendering to html" do
    before(:each) do
      @rendering.content.stub!(:body).and_return('Image has no body yet')
      @html = @rendering.render
    end
    it "should render proper html" do
      @html.should have_tag('div.rendering.simple_preview.image') do
        with_tag('h2','Irish Landscape')
        with_tag('p',/Image has no body yet/)
      end
    end
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
      @r = renderings(:main12).clone
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

end
