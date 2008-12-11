require File.dirname(__FILE__) + '/../spec_helper'

describe ImagesController do

  describe "Route generation" do
    it "should generate custom urls" do
      route_for({:controller => 'images', :action => 'custom', :geometry => '42x23', :filename => 'image_filename.jpg', :id => 5 }).should ==
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

end
