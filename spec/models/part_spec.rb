require File.dirname(__FILE__) + '/../spec_helper'

describe Part do
  before(:each) do
    @part = Part.new
  end

  it "should not be valid" do
    @part.should_not be_valid
  end

  describe 'with a proper name and filename' do
    before(:each) do
      @part = Part.new
      @part.name = 'General Preview'
      @part.filename = 'general_preview'
    end
    it "should be valid" do
      @part.should be_valid
    end
    it "should have correct filename with extention" do
      @part.filename_with_extention.should == '_general_preview.html.erb'
    end
    it "should have correct partial_name" do
      @part.partial_name.should == 'stock/general_preview'
    end
    it "should have correct absolute_partial_name" do
      @part.absolute_partial_name.should == '/parts/stock/general_preview.html.erb'
    end
    it "should have correct fullpath" do
      @part.fullpath.should match(%r~app/views/parts/stock/_general_preview.html.erb~)
    end
    it "should not write its rhtml to a file (because it is empty)" do
      File.stub!(:open).with(any_args()).and_return(true)
      File.should_not_receive(:open).with(@part.fullpath,'w')
      lambda { @part.save! }.should_not raise_error
    end

    describe "but if we set some content into it" do
      before(:each) do
        @part.rhtml = '<p>some content</p>'
      end
      it "should write its rhtml to a file" do
        File.stub!(:open).with(any_args()).and_return(true)
        File.should_receive(:open).with(@part.fullpath,'w')
        lambda { @part.save! }.should_not raise_error
      end
    end
  end

  it "should have an empty options Hash" do
    @part.options.should == {}
  end

  it "should have a proper yaml representation of an empty hash" do
    @part.options_as_yaml.should == {}.to_yaml
  end

  describe "after setting a key in the options (as hash)" do
    before(:each) do
      @part.options[:how_often] = 5
    end
    it "should have this valua in the hash" do
      @part.options[:how_often].should == 5
    end
    it "should have a hash that contains exactly this setting" do
      @part.options.should == {:how_often => 5}
    end
    it "should have a proper yaml representation" do
      @part.options_as_yaml.should == "--- \n:how_often: 5\n"
    end
  end

  describe "after setting a key in the options (as yaml string)" do
    before(:each) do
      @part.options_as_yaml = "---\n:how_often: 5\n\n"
    end
    it "should have this value in the hash" do
      @part.options[:how_often].should == 5
    end
    it "should have a hash that contains exactly this setting" do
      @part.options.should == {:how_often => 5}
    end
    it "should have a proper yaml representation" do
      @part.options_as_yaml.should == "--- \n:how_often: 5\n"
    end
  end
end


describe Part, 'with a name and filename with spaces' do
  before(:each) do
    @part = Part.new
    @part.name = 'Another Preview'
    @part.filename = 'i have spaces'
  end
  it "should not be valid" do
    @part.should_not be_valid
    @part.should have_at_least(1).errors_on(:filename)
  end
  after(:each) do
    @part = nil
  end
end

describe Part, 'with a filename called "filename"' do
  before(:each) do
    @part = Part.new
    @part.filename = 'filename'
  end
  it "should not be valid" do
    @part.should have_at_least(1).errors_on(:filename)
  end
end


describe "A Part with plain HTML in it" do
  before(:each) do
    @part = Part.new(
      :name => 'Pure HTML',
      :filename => 'pure_html',
      :rhtml => "<h1>Headline</h1>\n<p>Some Text</p>"
    )
  end
  it "should be valid" do
    @part.should be_valid
  end

  it "should render to the same HTML" do
    @part.render(binding).should == @part.rhtml
  end
end

describe "A Part with non-matching HTML-tags in it" do
  before(:each) do
    @part = Part.new(
      :name => 'Bad HTML',
      :filename => 'bad_html',
      :rhtml => "<h1>Headline</h1>\n<p>Some Text without closing p"
    )
  end
  it "should not be valid" do
    @part.should_not be_valid
  end

  it "should have an error on rhtml" do
    @part.valid?
    @part.should have_at_least(1).errors_on(:rhtml)
  end

  it "should render to the same HTML (even if it is invalid)" do
    @part.render(binding).should == @part.rhtml
  end
end

describe "A Part with a bit ERB calculations in it" do
  before(:each) do
    @part = Part.new(
      :name => 'Math HTML',
      :filename => 'math_html',
      :rhtml => "<p><%= 4 + 8 + 15 + 16 + 23 + 42 %></p>"
    )
  end
  it "should be valid" do
    @part.should be_valid
  end

  it "should render the calculation" do
    @part.render(binding).should == '<p>108</p>'
  end
end

describe "A Part with malformed erb in it" do
  before(:each) do
    @part = Part.new(
      :name => 'Malformed ERB',
      :filename => 'malformed_rhtml',
      :rhtml => "<h1>Headline <%= 5+ %></h1>"
    )
  end
  it "should not be valid" do
    @part.should_not be_valid
  end

  it "should have an error on rhtml" do
    @part.valid?
    @part.should have_at_least(1).errors_on(:rhtml)
  end

  it "should raise an error on rendering" do
    lambda { @part.render(binding).should }.should raise_error
  end
end

describe "A Part with evil erb in it" do
  before(:each) do
    @part = Part.new(
      :name => 'evil ERB',
      :filename => 'evil_rhtml',
      :rhtml => "<h1>Headline <%= User.find(1).id %></h1>"
    )
  end
  it "should not be valid" do
    pending("Evil code is allowed.. cannot override save level properly")
    @part.should_not be_valid
  end

  it "should have an error on rhtml" do
    pending("Evil code is allowed.. cannot override save level properly")
    @part.valid?
    @part.should have_at_least(1).errors_on(:rhtml)
  end

  it "should raise an security error on rendering" do
    pending("Evil code is allowed.. cannot override save level properly")
    #$SAFE = 3 # this is actually set in @part.render, but the specs don't like it on the :all run
    lambda { @part.render }.should raise_error(SecurityError)
  end
end

describe "A Part with ERB that accesses an Object of the same name" do
  before(:each) do
    @part = Part.new(
      :name => 'Content Preview',
      :filename => 'content_preview',
      :rhtml => %Q[<h1><%= content_preview.title %></h1>\n<p><%= content_preview.body %></p>],
      :preferred_types => [Document]
    )
  end
  it "should be valid" do
    @part.should be_valid
  end
  describe "given a @content in a PartController binding" do
    before(:each) do
      @content = mock_model(Content)
      @content.stub!(:title).and_return("My Title")
      @content.stub!(:body).and_return("A not so long Paragraph")
    end
    it "should render the attributes of the content correctly" do
      @part.render_with_content(@content).should == %Q[<h1>My Title</h1>\n<p>A not so long Paragraph</p>]
    end
    describe "And if we add some helper calls to the :rhtml" do
      before(:each) do
        @part.rhtml = %Q[<h1><%=h content_preview.title.upcase %></h1>\n<p><%=h truncate(content_preview.body,10) %></p>]
      end
      it "should render this, too" do
        @part.render_with_content(@content).should == %Q[<h1>MY TITLE</h1>\n<p>A not s...</p>]
      end
    end
  end
end

describe "The simple preview Part" do
  fixtures :all
  before(:each) do
    @part = parts(:simple_preview)
  end

  it "should be located in the correct directory" do
    @part.fullpath.should =~ %r~app/views/parts/stock/_simple_preview.html.erb$~
  end

  it "should know about its path for a given a theme" do
    @part.fullpath('cool_theme').should =~ %r~themes/cool_theme/views/parts/stock/_simple_preview.html.erb$~
  end

  it "should know about its path in the theme if we want to use a theme" do
    @part.use_theme = true
    @part.fullpath.should =~ %r~themes/default/views/parts/stock/_simple_preview.html.erb$~
  end

  it "should know about its path in the theme if we want to use a theme, set in the controller" do
    @part.use_theme = true
    @part.should_receive(:current_theme).and_return('cool_theme')
    @part.fullpath.should =~ %r~themes/cool_theme/views/parts/stock/_simple_preview.html.erb$~
  end

  it "should know it is in the theme if the part file exists there" do
    File.should_receive(:exists?).with(%r~themes/cool_theme/views/parts/stock/_simple_preview.html.erb$~).and_return(true)
    @part.should be_in_theme('cool_theme')
  end
  it "should know it is not in the theme if the part file does not exist there" do
    File.should_receive(:exists?).with(%r~themes/cool_theme/views/parts/stock/_simple_preview.html.erb$~).and_return(false)
    @part.should_not be_in_theme('cool_theme')
  end

end
