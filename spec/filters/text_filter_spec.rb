require File.dirname(__FILE__) + '/../spec_helper'

describe TextFilter, :type => :helper do

  before( :each ) do
    @filter = Object.new
    @filter.extend TextFilter
  end

  describe "brekkify-ing" do

    def f(text)
      @filter.brekkify(text)
    end

    def have_img_tag_for(image)
      have_tag('img[src=?][alt=?]', image.url, image.title)
    end
    def with_img_tag_for(image)
      with_tag('img[src=?][alt=?]', image.url, image.title)
    end

    describe "[image] tags" do

      before( :each ) do
        @image = mock_model(Image, :url => '/images/23.jpg', :title => 'My Image', :id => 23, :slug => 'my-image')
        Image.stub!(:find_by_id).with("23").and_return(@image)
        Image.stub!(:find_by_id).with(23).and_return(@image)
        Image.stub!(:find_by_slug).with("my-image").and_return(@image)
      end

      it "should find image by id" do
        Image.should_receive(:find_by_id).with(23).and_return(@image)
        f("[image:23]").should have_img_tag_for(@image)
      end

      it "should find image by slug" do
        Image.should_receive(:find_by_slug).with("my-image").and_return(@image)
        f("[image:my-image]").should have_img_tag_for(@image)
      end


      describe "giving {}" do
        it "should show image with its title under it" do
          f("[image:23]{}").should have_tag('div.image') do
            with_img_tag_for(@image)
            with_tag('span.title', @image.title)
          end
        end
      end

      describe "giving {Extra Description}" do
        it "should show image with Extra Description under it" do
          f("[image:23]{Extra Description}").should have_tag('div.image') do
            with_img_tag_for(@image)
            with_tag('span.title', 'Extra Description')
          end
        end
      end
      
    end

    
  end

end

