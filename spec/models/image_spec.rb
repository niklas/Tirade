require File.dirname(__FILE__) + '/../spec_helper'

describe Image do
  before(:each) do
    @photo = ActionController::TestUploadedFile.new( File.join(RAILS_ROOT,'public','images', 'pentagon-tile.jpg'), 'image/jpg' )
    @image = Image.new(:image => @photo)
  end

  it "should not be valid (need image)" do
    @image.should be_valid
  end

  it "should be intergrated with paperclip" do
    @image.should respond_to(:image)
  end
end

describe "The Landscape Image" do
  before(:each) do
    Image.attachment_definitions[:image][:path] = ':rails_root/spec/fixtures/:attachment/:id/:style/:basename.:extension'
    @image = Factory :image, :title => 'Irish Landscape', :image_file_name => 'irish_landscape.jpg', :id => 55
  end

  it "should be there" do
    @image.should_not be_nil
  end

  it "should have an original_filename" do
    @image.image.original_filename.should_not be_blank
  end

  describe "creating a custom thumbnail" do
    before(:each) do
      @geom = '200x100'
      @custom_dir = RAILS_ROOT+'/spec/fixtures/images/55/custom/200x100'
      @custom_path = @custom_dir + '/irish_landscape.jpg'
      @custom_style = "custom200x100"

      FileUtils.should_receive(:mkdir_p).with(@custom_dir).and_return(true)

      io_mock = mock(File)
      io_mock.stub!(:write).and_return(true)
      io_mock.stub!(:rewind).and_return(true)

      File.should_receive(:new).with(@custom_path,'wb+').and_return(io_mock)
      #@image.image.should_receive(:exists?).with(@custom_style).and_return(true)

      @custom_url = @image.custom_thumbnail_url(@geom)
    end

    it "should have an url with the given geom in it" do
      @custom_url.should =~ %r~/images/55/custom/200x100/irish_landscape.jpg$~
    end
  end

  describe "creating a custom thumbnail with cropping" do
    before(:each) do
      @geom = '200x100#'
      @custom_dir = RAILS_ROOT+'/spec/fixtures/images/55/custom/200x100#'
      @custom_path = @custom_dir + '/irish_landscape.jpg'
      @custom_style = "custom/200x100#"

      FileUtils.should_receive(:mkdir_p).with(@custom_dir).and_return(true)

      io_mock = mock(File)
      io_mock.stub!(:write).and_return(true)
      io_mock.stub!(:rewind).and_return(true)

      File.should_receive(:new).with(@custom_path,'wb+').and_return(io_mock)
      #@image.image.should_receive(:exists?).with(@custom_style).and_return(true)

      @custom_url = @image.custom_thumbnail_url(@geom)
    end

    it "should have an url with the given geom in it" do
      @custom_url.should =~ %r~/images/55/custom/200x100%23/irish_landscape.jpg$~
    end
  end
end
