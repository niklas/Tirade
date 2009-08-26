require File.dirname(__FILE__) + '/../spec_helper'

describe ImagesController do

  describe "Route generation" do
    it "should generate custom urls" do
      route_for({:controller => 'images', :action => 'custom', :geometry => '42x23', :filename => 'image_filename.jpg', :id => '5' }).should ==
        '/upload/images/5/custom/42x23/image_filename.jpg'
    end
  end

  describe "Route recognition" do
    it "should recognize custom urls without x" do
      params_from(:get, '/upload/images/5/custom/4223/image_filename.jpg').should == 
        {:controller => 'images', :action => 'custom', :geometry => '4223', :filename => 'image_filename.jpg', :id => "5"  }
    end
    it "should recognize custom urls" do
      params_from(:get, '/upload/images/5/custom/42x23/image_filename.jpg').should == 
        {:controller => 'images', :action => 'custom', :geometry => '42x23', :filename => 'image_filename.jpg', :id => "5"  }
    end
  end

  describe "using Toolbox" do
    before( :each ) do
      login_standard
      login_with_groups :admin_images
    end

    describe "uploading an image (multipart)" do
      def do_request
        filename = "%s/%s/%s" % [ File.dirname(__FILE__), '../../public/images', 'pentagon-tile.jpg' ]
        file = ActionController::TestUploadedFile.new(filename)
        Image.any_instance.stubs(:valid?).returns(true)
        Image.any_instance.stubs(:save).returns(true)
        post :create, :image => {:image => file }, :format => 'js'
      end

      it "should be successful" do
        do_request
        response.should be_success
      end

      it "should wrap the JS response into HTML for iframe support" do
        do_request
        response.body.should have_tag('html > body > script[type=text/javascript]', /window\.eval/)
      end
    end
    
  end

end
