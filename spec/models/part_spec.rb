require File.dirname(__FILE__) + '/../spec_helper'

describe Part do
  before(:each) do
    @defined_options = { 'how_often' => [:integer, 3]}
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
      @part.rhtml = ''
    end
    it "should be valid" do
      @part.should be_valid
    end
    it "should have theme support enabled" do
      @part.should_not be_use_theme
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
    it "should have correct existing fullpath" do
      @part.existing_fullpath.should match(%r~app/views/parts/stock/_general_preview.html.erb~)
    end
    it "should not write its rhtml to a file (because it is blank)" do
      #File.stub!(:open).with(any_args()).and_return(true)
      File.should_not_receive(:open).with(@part.existing_fullpath,'w')
      lambda { @part.save! }.should_not raise_error
    end

    describe "but if we set some content into it" do
      before(:each) do
        @part.rhtml = '<p>some content</p>'
      end
      it "should write its rhtml to a file" do
        File.stub!(:open).with(any_args()).and_return(true)
        File.should_receive(:open).with(@part.existing_fullpath,'w')
        lambda { @part.save! }.should_not raise_error
      end
    end
  end

  it "should have an empty options Hash" do
    @part.options.to_hash.should == {}
  end

  it "should have a proper yaml representation of an empty hash" do
    @part.options_as_yaml.should == {}.to_yaml
  end

  describe ", setting some defined_options as hash" do
    before(:each) do
      @part.defined_options = @defined_options
    end
    it "should know where to store them" do
      Part.acts_as_custom_configurable_options[:defined_in].should == :defined_options
    end
    it "should return them again" do
      @part.defined_options.should == @defined_options
    end
  end

  describe "after setting a key in the options (as method)" do
    before(:each) do
      @part.defined_options = @defined_options
      @part.options.how_often = 5
    end
    it "should have this value in the hash" do
      @part.options[:how_often].should == 5
    end
    it "should have this value as method" do
      @part.options.how_often.should == 5
    end
    it "should have a hash that contains exactly this setting" do
      @part.options.to_hash.should == {'how_often'=> 5}
    end
    it "should have a proper yaml representation" do
      @part.options_as_yaml.should == "--- \nhow_often: 5\n"
    end
  end

  describe "after setting a key in the options (as hash)" do
    before(:each) do
      @part.defined_options = @defined_options
      @part.options[:how_often] = 5
    end
    it "should have this value in the hash" do
      @part.options[:how_often].should == 5
    end
    it "should have this value as method" do
      @part.options.how_often.should == 5
    end
    it "should have a hash that contains exactly this setting" do
      @part.options.to_hash.should == {'how_often'=> 5}
    end
    it "should have a proper yaml representation" do
      @part.options_as_yaml.should == "--- \nhow_often: 5\n"
    end
  end

  describe "after setting a key in the options (as yaml string)" do
    before(:each) do
      @part.defined_options = @defined_options
      @part.options_as_yaml = "---\n:how_often: 5\n\n"
    end
    it "should have this value in the hash" do
      @part.options[:how_often].should == 5
    end
    it "should have a hash that contains exactly this setting" do
      @part.options.to_hash.should == {'how_often'=> 5}
    end
    it "should have a proper yaml representation" do
      @part.options_as_yaml.should == "--- \nhow_often: 5\n"
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
    @part.render.should == @part.rhtml
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
    @part.render.should == @part.rhtml
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
    @part.render.should == '<p>108</p>'
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
    lambda { @part.render.should }.should raise_error
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
      :preferred_types => ["Document"]
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
    @part.existing_fullpath.should =~ %r~app/views/parts/stock/_simple_preview.html.erb$~
  end

  it "should know about its path for a given a theme" do
    @part.fullpath_for_theme('cool_theme').should =~ %r~themes/cool_theme/views/parts/stock/_simple_preview.html.erb$~
  end

  it "should know it is in the theme if the part file exists there" do
    File.stub!(:exists?).with(%r~themes/cool_theme/views/parts/stock/_simple_preview.html.erb$~).and_return(true)
    @part.should be_in_theme('cool_theme')
  end
  it "should know it is not in the theme if the part file does not exist there" do
    File.should_receive(:exists?).with(%r~themes/cool_theme/views/parts/stock/_simple_preview.html.erb$~).and_return(false)
    @part.should_not be_in_theme('cool_theme')
  end

  describe "Setting the use theme flag" do
    describe "by boolean to true" do
      it "should use the theme" do
        @part.use_theme = true
        @part.should be_use_theme
      end
    end
    describe "by boolean to false" do
      it "should use the theme" do
        @part.use_theme = false
        @part.should_not be_use_theme
      end
    end
    describe "by string to true" do
      it "should use the theme" do
        @part.use_theme = "true"
        @part.should be_use_theme
      end
    end
    describe "by string to false" do
      it "should use the theme" do
        @part.use_theme = "false"
        @part.should_not be_use_theme
      end
    end
    describe "by number to true" do
      it "should use the theme" do
        @part.use_theme = 1
        @part.should be_use_theme
      end
    end
    describe "by number to false" do
      it "should use the theme" do
        @part.use_theme = 0
        @part.should_not be_use_theme
      end
    end
    describe "by stringified number to true" do
      it "should use the theme" do
        @part.use_theme = "1"
        @part.should be_use_theme
      end
    end
    describe "by stringified number to false" do
      it "should use the theme" do
        @part.use_theme = "0"
        @part.should_not be_use_theme
      end
    end
  end

  describe ", enabling theme support" do
    before(:each) do
      @part.use_theme = true
    end

    it "should use_theme" do
      @part.should be_use_theme
    end

    it "should know about its path in the default theme" do
      @part.fullpath.should =~ %r~themes/default/views/parts/stock/_simple_preview.html.erb$~
    end
    it "should know about its path in the theme set by the controller" do
      @part.should_receive(:current_theme).and_return('cool_theme')
      @part.fullpath.should =~ %r~themes/cool_theme/views/parts/stock/_simple_preview.html.erb$~
    end
  end


  describe "making it themable (file does not exist yet)" do
    before(:each) do
      @target_re = %r~themes/cool_theme/views/parts/stock/_simple_preview.html.erb$~
      @part.should_receive(:current_theme).any_number_of_times.and_return('cool_theme')

      File.stub!(:exists?).with(@target_re).once.and_return(false)
      
      @part.stub!(:save_rhtml_in_theme!).and_return(true)
      @part.make_themable!
    end

    it "should be in theme" do
      File.stub!(:exists?).with(@target_re).and_return(true)
      @part.should_not be_nil
      @part.should be_in_theme
    end

    it "should save the rhtml to the theme location" do
      @part.stub!(:save_rhtml_to!).with(@target_re).and_return(true)
      @part.save
    end
  end

end


describe "A Part with content_numerus/_quantum" do
  it "can render no Content"
  it "can render a single Content"
  it "can render a collection of Contents"
end
