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
    end
    it "should be valid" do
      @part.should be_valid
    end
    it "should have theme support enabled" do
      @part.should_not be_use_theme
    end
    it "should keep correct filename" do
      @part.filename.should == 'general_preview'
    end
    it "should know its extention" do
      @part.extention.should == 'html.liquid'
    end
    it "should have correct filename with extention" do
      @part.filename_with_extention.should == 'general_preview.html.liquid'
    end
    it "should have correct partial_name" do
      @part.partial_name.should == 'stock/general_preview'
    end
    it "should have correct existing fullpath" do
      @part.active_path.should match(%r~/parts/stock/general_preview.html.liquid~)
    end
    it "should not write its liquid to a file (because it is blank)" do
      #File.stub!(:open).with(any_args()).and_return(true)
      File.should_not_receive(:open).with(@part.liquid_theme_path,'w')
      File.should_not_receive(:open).with(@part.liquid_stock_path,'w')
      lambda { @part.save! }.should_not raise_error
    end

    describe "but if we set some content into it" do
      before(:each) do
        @part.liquid = '<p>some content</p>'
      end
      it "should write its liquid to a file" do
        File.stub!(:open).with(any_args()).and_return(true)
        File.should_receive(:open).with(@part.liquid_theme_path,'w')
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
      :liquid => "<h1>Headline</h1>\n<p>Some Text</p>"
    )
  end
  it "should be valid" do
    @part.should be_valid
  end

  it "should render to the same HTML" do
    @part.render.should == @part.liquid
  end
end

describe "A Part with non-matching HTML-tags in it" do
  before(:each) do
    @part = Part.new(
      :name => 'Bad HTML',
      :filename => 'bad_html',
      :liquid => "<h1>Headline</h1>\n<p>Some Text without closing p"
    )
  end
  it "should not be valid" do
    @part.should_not be_valid
  end

  it "should have an error on liquid" do
    @part.valid?
    @part.should have_at_least(1).errors_on(:html)
  end

  it "should render to the same HTML (even if it is invalid)" do
    @part.render.should == @part.liquid
  end
end

#describe "A Part with a bit Ruby calculations in it" do
#  before(:each) do
#    @part = Part.new(
#      :name => 'Math HTML',
#      :filename => 'math_html',
#      :liquid => "<p>{{ 4 + 8 + 15 + 16 + 23 + 42 }}</p>"
#    )
#  end
#  it "should be valid" do
#    @part.should be_valid
#  end
#
#  it "should render the calculation" do
#    @part.render.should == '<p>108</p>'
#  end
#end

describe "A Part with malformed liquid in it" do
  before(:each) do
    @part = Part.new(
      :name => 'Malformed Liquid',
      :filename => 'malformed_liquid',
      :liquid => "<h1>Headline {% on_space_to_much % }</h1>"
    )
  end
  it "should not be valid" do
    @part.should_not be_valid
  end

  it "should have an error on liquid" do
    @part.valid?
    @part.should have_at_least(1).errors_on(:liquid)
  end

  it "should raise an error on rendering" do
    lambda { @part.render.should }.should raise_error
  end
end

describe "A Part with Liquid that accesses an Object of the same name" do
  before(:each) do
    @part = Part.new(
      :name => 'Content Preview',
      :filename => 'content_preview',
      :liquid => %Q[<h1>{{ content_preview.title }}</h1>\n<p>{{ content_preview.body }}</p>],
      :preferred_types => ["Document"]
    )
  end
  it "should be valid" do
    @part.should be_valid
  end
  it "should have code" do
    @part.code.should_not be_blank
  end
  describe "given a @content in a PartController binding" do
    before(:each) do
      @content = Content.new(
        :title => "My Title",
        :body => "A not so long Paragraph"
      )
    end
    it "should render the attributes of the content correctly" do
      @part.render_with_content(@content).should == %Q[<h1>My Title</h1>\n<p>A not so long Paragraph</p>]
    end
    describe "And if we add some helper calls to the :liquid" do
      before(:each) do
        @part.liquid = %Q[<h1>{{ content_preview.title|upcase}}</h1>\n<p>{{ content_preview.body|truncate: 10}}</p>]
        @forwards = @part.options_with_object(@content)
      end
      it "should forward something" do
        @forwards.should_not be_empty
      end
      it "should forward the @content as :content_preview" do
        @forwards.should have_key(:content_preview)
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
    @part.active_path.should =~ %r~/parts/stock/simple_preview.html.liquid$~
  end

  it "should know about its path for a given a theme" do
    @part.theme_path('cool_theme').should =~ %r~themes/cool_theme/views/parts/stock/simple_preview.html.liquid$~
  end

  it "should know it is in the theme if the part file exists there" do
    File.stub!(:exists?).with(%r~themes/cool_theme/views/parts/stock/simple_preview.html.liquid$~).and_return(true)
    @part.should be_in_theme('cool_theme')
  end
  it "should know it is not in the theme if the part file does not exist there" do
    File.should_receive(:exists?).with(%r~themes/cool_theme/views/parts/stock/simple_preview.html.liquid$~).and_return(false)
    @part.should_not be_in_theme('cool_theme')
  end

end


describe "A Part with some valid Liquid markup" do
  before(:each) do
    @part = Part.new(
      :name => 'Short Preview',
      :filename => 'short_preview',
      :liquid => %Q[<h2>{{ short_preview.title }}</h2>\n<p>{{ short_preview.body|truncate: 200 }}</p>]
    )
  end

  it "should be valid" do
    @part.should be_valid
  end
end


describe "A Part with content_numerus/_quantum" do
  it "can render no Content"
  it "can render a single Content"
  it "can render a collection of Contents"
end
