require File.dirname(__FILE__) + '/../spec_helper'

describe Part do
  before(:each) do
    @part = Part.new
  end

  it "should not be valid" do
    @part.should_not be_valid
  end

  describe ', setting a name and filename' do
    before(:each) do
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
      @part.absolute_partial_name.should == '/parts/stock/general_preview'
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

  describe ', setting a name and filename with spaces' do
    before(:each) do
      @part.name = 'Another Preview'
      @part.filename = 'i have spaces'
    end
    it "should be valid" do
      @part.should_not be_valid
      @part.should have_at_least(1).errors_on(:filename)
    end
  end

  describe ', setting a filename called "filename"' do
    before(:each) do
      @part.filename = 'filename'
    end
    it "should not be valid" do
      @part.should have_at_least(1).errors_on(:filename)
    end
  end

end


describe "A Part with plain HTML in it" do
  before(:each) do
    @part = Part.new(
      :name => 'Pure HTML',
      :filename => 'pure_html',
      :rhtml => "<h1>Headline</h1>\n<p>Some Text</p>"
    )
    @part.template_binding = binding
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
    @part.template_binding = binding
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
    @part.template_binding = binding
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
    @part.template_binding = binding
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
      :rhtml => "<h1>Headline <%= User.find(1).name %></h1>"
    )
    @part.template_binding = binding
  end
  it "should not be valid" do
    @part.should_not be_valid
  end

  it "should have an error on rhtml" do
    @part.valid?
    @part.should have_at_least(1).errors_on(:rhtml)
  end

  it "should raise an security error on rendering" do
    $SAFE = 3 # this is actually set in @part.render, but the specs don't like it on the :all run
    lambda { @part.render(binding).should }.should raise_error(SecurityError)
  end
end

describe "A Part with ERB that accesses an Object of the same name" do
  before(:each) do
    @part = Part.new(
      :name => 'Content Preview',
      :filename => 'content_preview',
      :rhtml => %Q[<h1><%= content_preview.title %></h1>\n<p><%= content_preview.body %></p>]
    )
    @part.template_binding = binding
  end
  it "should be valid" do
    @part.should be_valid
  end
  describe "given a @content in a PartController binding" do
    before(:each) do
      @content = Object.new
      @content.stub!(:title).and_return("My Title")
      @content.stub!(:body).and_return("A not so long Paragraph")
      @controller = PartsController.new
      @controller.stub!(:h).with('MY TITLE').and_return("MY TITLE")
      @controller.stub!(:h).with('A not so ...').and_return("A not so ...")
      @controller.stub!(:truncate).and_return('A not so ...')
      @controller.instance_variable_set '@content', @content
      @binding = @controller.send(:binding)
      @part.template_binding = @binding
    end
    it "should render the attributes of the content correctly" do
      @part.render(@binding).should == %Q[<h1>My Title</h1>\n<p>A not so long Paragraph</p>]
    end
    describe "And if we add some helper calls to the :rhtml" do
      before(:each) do
        @part.rhtml = %Q[<h1><%=h content_preview.title.upcase %></h1>\n<p><%=h truncate(content_preview.body,10) %></p>]
      end
      it "should render this, too" do
        @part.render(@binding).should == %Q[<h1>MY TITLE</h1>\n<p>A not so ...</p>]
      end
    end
  end
end
